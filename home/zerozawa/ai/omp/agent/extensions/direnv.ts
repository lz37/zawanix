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
import { existsSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

// ─── State ───────────────────────────────────────────────────────

let envrcDir: string | undefined;
let envrcPath: string | undefined;
let fingerprint: string | undefined;
let cachedEnv: Record<string, string> = {};
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

function fileFingerprint(path: string): string | undefined {
 try {
  const st = statSync(path);
  return `${st.dev}:${st.ino}:${st.size}:${st.mtimeMs}`;
 } catch {
  return undefined;
 }
}

// ─── Silent load via Bun.spawn ──────────────────────────────────

async function loadEnv(dir: string): Promise<Record<string, string>> {
 const proc = Bun.spawn(["direnv", "export", "json"], {
  cwd: dir,
  stdout: "pipe",
  stderr: "ignore",
  env: process.env as Record<string, string>,
  timeout: 120_000,
 });

 const [stdout] = await Promise.all([proc.stdout.text(), proc.exited]);
 const trimmed = stdout.trim();
 if (!trimmed) return {};

 let parsed: unknown;
 try {
  parsed = JSON.parse(trimmed);
 } catch {
  return {};
 }
 if (typeof parsed !== "object" || parsed === null) return {};

 const result: Record<string, string> = {};
 for (const [key, value] of Object.entries(parsed)) {
  if (typeof value === "string") result[key] = value;
 }
 return result;
}

// ─── Refresh cache ──────────────────────────────────────────────

function refresh(ctxCwd: string, force: boolean): Promise<void> {
 if (loading && !force) return loading;

 loading = (async () => {
  const found = findEnvrc(ctxCwd);
  if (!found) {
   envrcDir = undefined;
   envrcPath = undefined;
   fingerprint = undefined;
   cachedEnv = {};
   return;
  }

  const dir = dirname(found);
  const fp = fileFingerprint(found);
  if (!force && envrcPath === found && fingerprint === fp) return;

  try {
   cachedEnv = await loadEnv(dir);
   envrcDir = dir;
   envrcPath = found;
   fingerprint = fp;
  } catch {
   cachedEnv = {};
  }
 })().finally(() => {
  loading = undefined;
 });

 return loading;
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
   // Ensure cache is loaded
   if (loading) await loading;
   const dir = envrcDir;
   if (!dir) {
    return {
     content: [{ type: "text", text: "No .envrc found in current or parent directories." }],
     isError: true,
    };
   }

   // Refresh cache if file changed
   if (envrcPath && fingerprint) {
    const fp = fileFingerprint(envrcPath);
    if (fp && fp !== fingerprint) {
     await refresh(ctx.cwd, true);
    }
   }

   try {
    const execOpts: AbortableExecSyncOptions = {
     cwd: dir,
     encoding: "utf-8",
     timeout: 300_000,
     maxBuffer: 10 * 1024 * 1024,
     shell: "/bin/bash",
     env: { ...process.env, ...cachedEnv },
     windowsHide: true,
     signal,
    };
    const output = execSync(params.command, execOpts);
    return {
     content: [{ type: "text", text: output || "(no output)" }],
     details: {},
    };
   } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
     content: [{ type: "text", text: `Command failed: ${msg}` }],
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
   if (loading) await loading;
   if (!envrcDir) {
    return {
     content: [{ type: "text", text: "No .envrc found in current or parent directories." }],
     isError: true,
    };
   }

   // Refresh if file changed
   if (envrcPath && fingerprint) {
    const fp = fileFingerprint(envrcPath);
    if (fp && fp !== fingerprint) {
     await refresh(ctx.cwd, true);
    }
   }

   const keys = Object.keys(cachedEnv);
   if (keys.length === 0) {
    return { content: [{ type: "text", text: "No direnv-managed env vars currently." }] };
   }

   const lines: string[] = [];
   for (const k of keys) {
    const v = cachedEnv[k];
    if (v === undefined) continue;
    const display = v.length > 200 ? v.slice(0, 200) + `... (${v.length} chars)` : v;
    lines.push(`${k}=${display}`);
   }

   return {
    content: [{ type: "text", text: `direnv env (${keys.length} vars):\n${lines.join("\n")}` }],
   };
  },
 });
}
