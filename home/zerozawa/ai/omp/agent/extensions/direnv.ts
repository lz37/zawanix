/**
 * direnv: direnv integration for OMP via custom tool.
 *
 * Registers a `direnv_shell` tool that runs commands in the project's
 * direnv environment. LLM uses it explicitly — no env injection into
 * regular bash calls, no TUI pollution, no LLM context pollution.
 *
 * Also provides `/direnv enable|disable` and caches env for fast execution.
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { execSync, type ExecSyncOptionsWithStringEncoding } from "node:child_process";
import { type ZodType } from "zod/v4";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

// ─── State ───────────────────────────────────────────────────────

type EnvDiff = Record<string, string | undefined>;

let envrcDir: string | undefined;
let envrcPath: string | undefined;
let fingerprint: string | undefined;
let cachedEnv: EnvDiff = {};
let loadError: string | undefined;
let loading: Promise<void> | undefined;

// ─── Find .envrc ────────────────────────────────────────────────

function findEnvrc(start: string): string | undefined {
 let dir = resolve(start);
 for (; ;) {
  const candidate = join(dir, ".envrc");
  if (existsSync(candidate)) return candidate;
  const parent = dirname(dir);
  if (parent === dir) return undefined;
  dir = parent;
 }
}

// ─── Fingerprint ────────────────────────────────────────────────

function fileFingerprint(path: string): string {
 try {
  const st = statSync(path);
  return `${st.dev}:${st.ino}:${st.size}:${st.mtimeMs}`;
 } catch (err) {
  const code = typeof err === "object" && err !== null && "code" in err
   ? String((err as { code?: unknown }).code)
   : "missing";
  return `missing:${code}`;
 }
}

function splitShellWords(line: string): string[] {
 const words: string[] = [];
 let current = "";
 let quote: "'" | "\"" | undefined;
 let escaping = false;
 let inWord = false;

 for (const ch of line) {
  if (escaping) {
   current += ch;
   escaping = false;
   inWord = true;
   continue;
  }
  if (ch === "\\" && quote !== "'") {
   escaping = true;
   inWord = true;
   continue;
  }
  if (quote) {
   if (ch === quote) quote = undefined;
   else current += ch;
   inWord = true;
   continue;
  }
  if (ch === "#") break;
  if (ch === "'" || ch === "\"") {
   quote = ch;
   inWord = true;
   continue;
  }
  if (/\s/.test(ch)) {
   if (inWord) {
    words.push(current);
    current = "";
    inWord = false;
   }
   continue;
  }
  current += ch;
  inWord = true;
 }

 if (escaping) current += "\\";
 if (inWord) words.push(current);
 return words;
}

function resolveWatchPath(baseDir: string, watched: string): string {
 if (watched === "~" && process.env.HOME) return process.env.HOME;
 if (watched.startsWith("~/") && process.env.HOME) {
  return join(process.env.HOME, watched.slice(2));
 }
 return resolve(baseDir, watched);
}

function watchedFilesFromEnvrc(path: string): string[] {
 const watched = new Set<string>();
 try {
  const baseDir = dirname(path);
  const text = readFileSync(path, "utf-8");
  for (const line of text.split(/\r?\n/)) {
   const words = splitShellWords(line);
   if (words[0] !== "watch_file") continue;
   for (const arg of words.slice(1)) {
    if (arg.length > 0) watched.add(resolveWatchPath(baseDir, arg));
   }
  }
 } catch {
  // Keep the .envrc fingerprint below; loadEnv will report the real error.
 }
 return [...watched].sort();
}

function envFingerprint(path: string): string {
 const paths = [path, ...watchedFilesFromEnvrc(path)];
 return paths.map((p) => `${p}:${fileFingerprint(p)}`).join("\n");
}

// ─── Output formatting ──────────────────────────────────────────

function describeError(err: unknown): string {
 return err instanceof Error && err.message ? err.message : String(err);
}

function formatOutput(label: string, output: string): string {
 const trimmed = output.trim();
 if (!trimmed) return `${label}: (empty)`;
 const limit = 4000;
 const display = trimmed.length > limit
  ? `${trimmed.slice(0, limit)}\n... (${trimmed.length - limit} chars truncated)`
  : trimmed;
 return `${label}:\n${display}`;
}

function outputToString(output: unknown): string {
 if (typeof output === "string") return output;
 if (output instanceof Uint8Array) return new TextDecoder().decode(output);
 return "";
}

function direnvLoadErrorText(): string {
 const location = envrcPath ? ` from ${envrcPath}` : "";
 return `Failed to load direnv environment${location}.\n${loadError ?? "Unknown error"}`;
}

function commandErrorText(command: string, err: unknown): string {
 const execError = err as Error & {
  status?: number | null;
  signal?: string | null;
  stdout?: unknown;
  stderr?: unknown;
 };
 const stdout = outputToString(execError.stdout);
 const stderr = outputToString(execError.stderr);
 const lines = ["Command failed.", `Command: ${command}`];
 if (typeof execError.status === "number") lines.push(`Exit code: ${execError.status}`);
 if (execError.signal) lines.push(`Signal: ${execError.signal}`);
 if (stdout.trim()) lines.push(formatOutput("stdout", stdout));
 if (stderr.trim()) lines.push(formatOutput("stderr", stderr));
 if (!stdout.trim() && !stderr.trim()) lines.push(`Error: ${describeError(err)}`);
 return lines.join("\n");
}

function mergedEnv(): Record<string, string | undefined> {
 const env: Record<string, string | undefined> = { ...process.env };
 for (const [key, value] of Object.entries(cachedEnv)) {
  if (value === undefined) delete env[key];
  else env[key] = value;
 }
 return env;
}

// ─── Silent load via Bun.spawn ──────────────────────────────────

async function loadEnv(dir: string): Promise<EnvDiff> {
 const proc = (() => {
  try {
   return Bun.spawn(["direnv", "export", "json"], {
    cwd: dir,
    stdout: "pipe",
    stderr: "pipe",
    env: process.env as Record<string, string>,
    timeout: 120_000,
   });
  } catch (err) {
   throw new Error(
    `Failed to start "direnv export json" in ${dir}: ${describeError(err)}\n`
    + `PATH=${process.env.PATH ?? "(unset)"}`,
   );
  }
 })();

 const [stdout, stderr, exitCode] = await Promise.all([
  proc.stdout.text(),
  proc.stderr.text(),
  proc.exited,
 ]);
 if (exitCode !== 0) {
  throw new Error(
   `direnv export json failed with exit code ${exitCode} in ${dir}.\n`
   + `${formatOutput("stderr", stderr)}\n`
   + `${formatOutput("stdout", stdout)}`,
  );
 }

 const trimmed = stdout.trim();
 if (!trimmed) return {};

 let parsed: unknown;
 try {
  parsed = JSON.parse(trimmed);
 } catch (err) {
  throw new Error(
   `direnv export json returned invalid JSON in ${dir}: ${describeError(err)}\n`
   + `${formatOutput("stdout", stdout)}\n`
   + `${formatOutput("stderr", stderr)}`,
  );
 }
 if (typeof parsed !== "object" || parsed === null) {
  throw new Error(`direnv export json returned ${typeof parsed}, expected an object.`);
 }

 const result: EnvDiff = {};
 for (const [key, value] of Object.entries(parsed)) {
  if (typeof value === "string") result[key] = value;
  else if (value === null) result[key] = undefined;
  else {
   throw new Error(
    `direnv export json returned unsupported value for ${key}: `
    + `${Object.prototype.toString.call(value)}`,
   );
  }
 }
 return result;
}

// ─── Refresh cache ──────────────────────────────────────────────

function clearState(): void {
 envrcDir = undefined;
 envrcPath = undefined;
 fingerprint = undefined;
 cachedEnv = {};
 loadError = undefined;
}

function refresh(ctxCwd: string, force: boolean): Promise<void> {
 if (loading) return loading;

 const refreshPromise = (async () => {
  const found = findEnvrc(ctxCwd);
  if (!found) {
   clearState();
   return;
  }

  const dir = dirname(found);
  const fp = envFingerprint(found);
  if (!force && envrcPath === found && fingerprint === fp && !loadError) return;

  try {
   cachedEnv = await loadEnv(dir);
   envrcDir = dir;
   envrcPath = found;
   fingerprint = envFingerprint(found);
   loadError = undefined;
  } catch (err) {
   envrcDir = dir;
   envrcPath = found;
   fingerprint = fp;
   cachedEnv = {};
   loadError = describeError(err);
  }
 })();

 const tracked = refreshPromise.finally(() => {
  if (loading === tracked) loading = undefined;
 });
 loading = tracked;
 return tracked;
}

async function ensureFresh(ctxCwd: string): Promise<string | undefined> {
 const hadLoading = loading !== undefined;
 if (loading) await loading;

 const found = findEnvrc(ctxCwd);
 if (!found) {
  if (envrcDir || envrcPath || fingerprint || loadError || Object.keys(cachedEnv).length > 0) {
   await refresh(ctxCwd, true);
  }
 } else {
  const fp = envFingerprint(found);
  if (envrcPath !== found || fingerprint !== fp || (loadError && !hadLoading)) {
   await refresh(ctxCwd, true);
  }
 }

 if (!envrcDir) return "No .envrc found in current or parent directories.";
 if (loadError) return direnvLoadErrorText();
 return undefined;
}

// ─── Extension entry point ───────────────────────────────────────

export default function direnvExtension(pi: ExtensionAPI) {
 const z = pi.zod;

 type DirenvShellParams = { command: string };
 type DirenvEnvParams = Record<string, never>;
 type AbortableExecSyncOptions = ExecSyncOptionsWithStringEncoding & {
  signal?: AbortSignal | undefined;
 };

 const direnvShellParameters: ZodType<DirenvShellParams> = z.object({
  command: z.string().describe("Shell command to execute in the direnv environment"),
 });
 const direnvEnvParameters: ZodType<DirenvEnvParams> = z.object({});
 pi.setLabel("Direnv");

 // Session start: silent cache
 pi.on("session_start", (_event, ctx) => {
  void refresh(ctx.cwd, true);
 });

 // ── direnv_shell custom tool ───────────────────────────────
 pi.registerTool<ZodType<DirenvShellParams>>({
  name: "direnv_shell",
  label: "Direnv Shell",
  description:
   "Run a shell command in the project's direnv environment (.envrc). "
   + "Regular bash already inherits the initial env vars, so use direnv_shell "
   + "when you need the LATEST env vars AFTER modifying direnv watch_files "
   + "(.envrc, flake.nix, devenv.yaml, flake.lock, etc.). "
   + "This tool re-evaluates the direnv environment to pick up your changes. "
   + "Note: modified env vars only apply within direnv_shell. "
   + "To apply them to ALL tools, ask the user to restart the OMP session "
   + "once the current milestone is complete and you're ready for a clean reload.",
  parameters: direnvShellParameters,
  async execute(_toolCallId, params, signal, _onUpdate, ctx) {
   const loadProblem = await ensureFresh(ctx.cwd);
   if (loadProblem) {
    return {
     content: [{ type: "text", text: loadProblem }],
     isError: true,
    };
   }
   const dir = envrcDir;
   if (!dir) {
    return {
     content: [{ type: "text", text: "No .envrc found in current or parent directories." }],
     isError: true,
    };
   }

   try {
    const execOpts: AbortableExecSyncOptions = {
     cwd: dir,
     encoding: "utf-8",
     timeout: 300_000,
     maxBuffer: 10 * 1024 * 1024,
     shell: "/bin/bash",
     env: mergedEnv(),
     stdio: "pipe",
     windowsHide: true,
     signal,
    };
    const output = execSync(params.command, execOpts);
    return {
     content: [{ type: "text", text: output || "(no output)" }],
     details: {},
    };
   } catch (err) {
    return {
     content: [{ type: "text", text: commandErrorText(params.command, err) }],
     isError: true,
    };
   }
  },
 });


 // ── direnv_env: expose current env diff ───────────────────
 pi.registerTool<ZodType<DirenvEnvParams>>({
  name: "direnv_env",
  label: "Direnv Environment",
  description:
   "Show the current direnv-managed environment variables (the diff that "
   + "direnv export json would return). Use this to inspect what env vars "
   + "are available in the project's direnv environment after modifications "
   + "to .envrc, flake.nix, devenv.yaml, etc. "
   + "Read-only, no side effects.",
  parameters: direnvEnvParameters,
  async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
   const loadProblem = await ensureFresh(ctx.cwd);
   if (loadProblem) {
    return {
     content: [{ type: "text", text: loadProblem }],
     isError: true,
    };
   }

   const keys = Object.keys(cachedEnv);
   if (keys.length === 0) {
    const from = envrcPath ? ` Loaded .envrc: ${envrcPath}.` : "";
    return { content: [{ type: "text", text: `No direnv-managed env vars currently.${from}` }] };
   }

   const lines: string[] = [];
   for (const k of keys) {
    const v = cachedEnv[k];
    if (v === undefined) {
     lines.push(`${k}=<unset>`);
     continue;
    }
    const display = v.length > 200 ? v.slice(0, 200) + `... (${v.length} chars)` : v;
    lines.push(`${k}=${display}`);
   }

   const from = envrcPath ? ` from ${envrcPath}` : "";
   return {
    content: [{ type: "text", text: `direnv env (${keys.length} changes${from}):\n${lines.join("\n")}` }],
   };
  },
 });
}
