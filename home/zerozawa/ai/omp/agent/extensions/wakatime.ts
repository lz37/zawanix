import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

/**
 * WakaTime integration for OMP.
 *
 * Tracks file changes from tool results and sends heartbeats to WakaTime
 * via the wakatime-cli binary. Aligned with the official vscode-wakatime
 * and wakatime-cli AI protocol (wakatime-cli 2.x):
 *
 * - Buffers changes and flushes at most one CLI process per 60s: first
 *   heartbeat as CLI flags, the rest as `--extra-heartbeats` JSON on stdin.
 * - `--category "ai coding"` on every heartbeat: all activity in an OMP
 *   session is AI coding activity (matches upstream AI heartbeats).
 * - Real `--ai-line-changes` per file, computed from unified diffs the same
 *   way wakatime-cli's own transcript parser does (pkg/ai/pi.go).
 * - Current model embedded in the plugin User-Agent token (e.g.
 *   `deepseek/4-pro`, `gpt/5.6-sol`), same UA convention the CLI uses for
 *   AI transcripts (pkg/ai: aiUserAgentWithModel / aiModelUserAgentToken).
 *   There is no dedicated model field in the heartbeat API — the
 *   User-Agent is the only model channel. `ai_session`/`ai_input_tokens`/
 *   `ai_output_tokens` exist in the API but are only populated by the CLI's
 *   own transcript parsers, not settable via flags or extra heartbeats.
 * - Project resolved by a local sync `.git`/`commondir` walk (ported from
 *   OMP ≤17's `repo.primaryRootSync`, which OMP 18 removed when VCS
 *   detection moved into the native pi-natives binding), sent as
 *   --alternate-project + --project-folder.
 * - Fires a debounced `--sync-ai-activity` every 120s so wakatime-cli's own
 *   AI transcript parsers (Claude/Codex/Cursor/…) sync even when no OMP
 *   file activity triggers a flush.
 *
 * Installation: Add to ~/.omp/agent/config.yml:
 *   extensions: ["~/.omp/agent/extensions/wakatime.ts"]
 *
 * Requires: wakatime-cli on PATH (provided by nixpkgs.wakatime-cli).
 */
export default function(pi: ExtensionAPI) {
 pi.setLabel("WakaTime");

 // ── Constants ──────────────────────────────────────────
 const FLUSH_INTERVAL_S = 60;
 const AI_SYNC_INTERVAL_MS = 120_000;
 const CLI_WAKATIME = "wakatime-cli";
 const EXT_VERSION = "1.2.0";
 const AI_CATEGORY = "ai coding";

 // ── State ──────────────────────────────────────────────
 interface FileChange {
  /** Signed accumulated lines added/removed by AI since last flush. */
  aiLineChanges: number;
  isWrite: boolean;
  /** Unix seconds (float) of the latest change. */
  lastTime: number;
 }
 const fileChanges = new Map<string, FileChange>();
 const seenCallIds = new Set<string>();
 let lastFlushAt = 0;
 let sessionCtx: ExtensionContext | undefined;
 let ompVersion: string | undefined;
 let projectFolder = process.cwd();
 let projectName = "";

 // ── Helpers ────────────────────────────────────────────

 /**
  * Primary checkout root via a sync `.git`/`commondir` walk, no subprocess.
  * Local port of OMP ≤17's `pi.pi.repo.primaryRootSync` — OMP 18 removed that
  * export when VCS detection moved into the native @oh-my-pi/pi-natives
  * binding, which extensions cannot portably import. Returns null outside any
  * repository. Bare-repo worktrees resolve to the shared common dir (foo.git).
  */
 function primaryRootSync(cwd: string): string | null {
  let dir = cwd;
  for (; ;) {
   const entry = path.join(dir, ".git");
   let isDir = false;
   let isFile = false;
   try {
    const st = fs.statSync(entry);
    isDir = st.isDirectory();
    isFile = st.isFile();
   } catch {
    // No .git entry here — keep walking up.
   }
   if (isDir) return dir; // Regular checkout: common dir is the .git dir itself.
   if (isFile) {
    // Linked worktree or submodule: the .git file carries "gitdir: <path>".
    try {
     const raw = fs.readFileSync(entry, "utf8");
     const target = /^gitdir:\s*(.+?)\s*$/m.exec(raw)?.[1];
     if (!target) return null;
     const gitDir = path.isAbsolute(target) ? target : path.resolve(dir, target);
     let commonDir = gitDir;
     try {
      const link = fs.readFileSync(path.join(gitDir, "commondir"), "utf8").trim();
      commonDir = path.isAbsolute(link) ? link : path.resolve(gitDir, link);
     } catch {
      // Submodule layout: no commondir file → common dir is the git dir.
     }
     if (commonDir === gitDir) return dir;
     return path.basename(commonDir) === ".git" ? path.dirname(commonDir) : commonDir;
    } catch {
     return null;
    }
   }
   const parent = path.dirname(dir);
   if (parent === dir) return null;
   dir = parent;
  }
 }

 /** Resolve the project root via the local git worktree walk. */
 function resolveProject(ctx: ExtensionContext): void {
  const cwd = ctx.cwd || process.cwd();
  projectFolder = primaryRootSync(cwd) ?? cwd;
  let base = projectFolder.split("/").filter(Boolean).pop() ?? "";
  if (base.endsWith(".git")) base = base.slice(0, -4);
  projectName = base;
 }

 /** Detect OMP version once per session for the User-Agent. */
 async function detectOmpVersion(): Promise<void> {
  try {
   const res = await pi.exec("omp", ["--version"], { timeout: 5000 });
   const m = /omp\/(\S+)/.exec(res.stdout.trim());
   if (m) ompVersion = m[1];
  } catch {
   // Optional — UA just omits the omp token.
  }
 }

 /**
  * Port of wakatime-cli's aiModelUserAgentToken (pkg/ai/ai.go).
  * Turns a model id like "litellm/deepseek-v4-pro" into a UA token
  * "deepseek/4-pro"; "gpt-5.6-sol" → "gpt/5.6-sol"; "k3" → "k/3".
  */
 function modelUAToken(modelId: string): string {
  let model = modelId.trim().replace(/\s+/g, "-").replace(/^\/+|\/+$/g, "");
  if (!model) return "";

  const firstSlash = model.indexOf("/");
  if (firstSlash > 0 && firstSlash < model.length - 1) {
   const version = model.slice(firstSlash + 1);
   const code = version.charCodeAt(0);
   if (code >= 48 && code <= 57) {
    return `${model.slice(0, firstSlash)}/${version}`;
   }
  }

  const lastSlash = model.lastIndexOf("/");
  if (lastSlash !== -1) {
   model = model.slice(lastSlash + 1).replace(/^[-_.]+|[-_.]+$/g, "");
  }

  const parts = model.split(/[-_]/).filter((p) => p.length > 0);
  for (let i = 0; i < parts.length; i++) {
   const part = parts[i];
   if (!part) continue;
   for (let j = 0; j < part.length; j++) {
    const code = part.charCodeAt(j);
    if (code < 48 || code > 57) continue;
    if (j === 0) {
     if (i === 0) return "";
     const prev = parts[i - 1];
     return prev ? `${prev}/${parts.slice(i).join("-")}` : "";
    }
    let product = part.slice(0, j);
    if (product.toLowerCase() === "v" && i > 0) product = parts[i - 1] ?? product;
    let version = part.slice(j);
    if (i + 1 < parts.length) version += `-${parts.slice(i + 1).join("-")}`;
    return `${product}/${version}`;
   }
  }
  return "";
 }

 /** Plugin User-Agent: omp/<ver> [<model-token>] omp-wakatime/<ver>. */
 function userAgent(): string {
  const parts: string[] = [];
  if (ompVersion) parts.push(`omp/${ompVersion}`);
  const model = sessionCtx?.model;
  if (model) {
   const token = modelUAToken(`${model.provider}/${model.id}`);
   if (token) parts.push(token);
  }
  parts.push(`omp-wakatime/${EXT_VERSION}`);
  return parts.join(" ");
 }

 /**
  * Signed line changes from a unified diff, mirroring
  * wakatime-cli's piDiffLineChanges (pkg/ai/pi.go).
  */
 function diffLineChanges(diff: string): number {
  let additions = 0;
  let deletions = 0;
  for (const line of diff.split("\n")) {
   if (line.startsWith("+++") || line.startsWith("---") || line.startsWith("@@")) continue;
   if (line.startsWith("+")) additions++;
   else if (line.startsWith("-")) deletions++;
  }
  return additions - deletions;
 }

 /** Line count of file content (for full-file writes). */
 function contentLineCount(text: string): number {
  if (text.length === 0) return 0;
  const n = text.split("\n").length;
  return text.endsWith("\n") ? n - 1 : n;
 }

 /** Only local absolute file paths are valid heartbeat entities. */
 function normalizeEntity(file: string, cwd: string): string | undefined {
  if (!file || file.includes("://")) return undefined;
  if (file.startsWith("/")) return file;
  return `${cwd}/${file}`;
 }

 /** Record a file change in the buffer. */
 function trackFile(file: string, lineDelta: number, isWrite: boolean): void {
  const now = Date.now() / 1000;
  const existing = fileChanges.get(file);
  if (existing) {
   existing.aiLineChanges += lineDelta;
   existing.isWrite ||= isWrite;
   existing.lastTime = now;
  } else {
   fileChanges.set(file, { aiLineChanges: lineDelta, isWrite, lastTime: now });
  }
 }

 /** Deduplicate tool call IDs. Returns false if already seen. */
 function dedupCall(callId: string): boolean {
  if (seenCallIds.has(callId)) return false;
  seenCallIds.add(callId);
  if (seenCallIds.size > 2000) {
   const toRemove: string[] = [];
   let i = 0;
   for (const id of seenCallIds) {
    if (i++ >= 1000) break;
    toRemove.push(id);
   }
   for (const id of toRemove) seenCallIds.delete(id);
  }
  return true;
 }

 /** Extract file path from a tool result event, regardless of tool type. */
 function getEventPath(input: Record<string, unknown>, details: unknown): string | undefined {
  const inputPath = input.path as string | undefined;
  if (inputPath && typeof inputPath === "string") return inputPath;

  if (details && typeof details === "object") {
   const d = details as Record<string, unknown>;
   const detailPath = (d.path ?? d.resolvedPath) as string | undefined;
   if (detailPath && typeof detailPath === "string") return detailPath;
  }
  return undefined;
 }

 // ── Heartbeat sending ──────────────────────────────────

 interface HeartbeatEntry {
  entity: string;
  time: number;
  isWrite: boolean;
  aiLineChanges: number;
 }

 /** Extra-heartbeat JSON entry (wakatime-cli pkg/params ExtraHeartbeat). */
 function toExtraHeartbeat(h: HeartbeatEntry): Record<string, unknown> {
  const json: Record<string, unknown> = {
   entity: h.entity,
   type: "file",
   time: h.time,
   category: AI_CATEGORY,
   is_write: h.isWrite,
  };
  if (h.aiLineChanges !== 0) json.ai_line_changes = h.aiLineChanges;
  if (projectName) json.alternate_project = projectName;
  return json;
 }

 /** CLI args for the primary heartbeat (extras go via stdin). */
 function buildArgs(h: HeartbeatEntry, withExtras: boolean): string[] {
  const args: string[] = [
   "--entity", h.entity,
   "--entity-type", "file",
   "--time", String(h.time),
   "--category", AI_CATEGORY,
   "--plugin", userAgent(),
   "--project-folder", projectFolder,
  ];
  if (projectName) args.push("--alternate-project", projectName);
  if (h.aiLineChanges !== 0) args.push("--ai-line-changes", String(h.aiLineChanges));
  if (h.isWrite) args.push("--write");
  if (withExtras) args.push("--extra-heartbeats");
  return args;
 }

 function logFailure(file: string, info: string): void {
  pi.logger?.debug?.(`[WakaTime] heartbeat failed for ${file}: ${info}`);
 }

 /** Send one batch via Bun.spawn with extra heartbeats on stdin. */
 async function sendBatched(entries: HeartbeatEntry[]): Promise<void> {
  if (typeof Bun === "undefined" || !Bun) throw new Error("Bun unavailable");
  const main = entries[0];
  if (!main) return;
  const extras = entries.slice(1);
  const proc = Bun.spawn([CLI_WAKATIME, ...buildArgs(main, extras.length > 0)], {
   stdin: "pipe",
   stdout: "ignore",
   stderr: "ignore",
  });
  if (extras.length > 0) {
   proc.stdin.write(`${JSON.stringify(extras.map(toExtraHeartbeat))}\n`);
  }
  proc.stdin.end();
  const code = await proc.exited;
  if (code !== 0) logFailure(main.entity, `exit ${code}`);
 }

 /** Fallback: one CLI process per heartbeat via pi.exec. */
 async function sendIndividually(entries: HeartbeatEntry[]): Promise<void> {
  for (const h of entries) {
   const res = await pi.exec(CLI_WAKATIME, buildArgs(h, false)).catch(() => undefined);
   if (!res) continue;
   if (res.code !== 0) logFailure(h.entity, res.stderr?.trim() || res.stdout?.trim());
  }
 }

 /** Flush buffered changes as one CLI invocation (rate-limited). */
 async function flushHeartbeats(force = false): Promise<void> {
  if (fileChanges.size === 0) return;

  const now = Math.floor(Date.now() / 1000);
  if (!force && now - lastFlushAt < FLUSH_INTERVAL_S) return;
  lastFlushAt = now;

  const entries: HeartbeatEntry[] = [];
  for (const [entity, change] of fileChanges) {
   entries.push({
    entity,
    time: change.lastTime,
    isWrite: change.isWrite,
    aiLineChanges: change.aiLineChanges,
   });
  }
  fileChanges.clear();

  // Most recent activity first — it becomes the flag-carried heartbeat.
  entries.sort((a, b) => b.time - a.time);

  const promise = (async () => {
   try {
    await sendBatched(entries);
   } catch {
    await sendIndividually(entries).catch(() => {
     // Heartbeat failures must never crash the agent.
    });
   }
  })();

  if (force) await promise;
 }

 /** Trigger wakatime-cli's own AI transcript sync (Claude/Codex/Cursor/…). */
 function syncAIHeartbeats(): void {
  const args = ["--sync-ai-activity", "--plugin", userAgent(), "--project-folder", projectFolder];
  if (projectName) args.push("--alternate-project", projectName);
  pi.exec(CLI_WAKATIME, args).catch(() => {
   // Optional background sync — ignore failures.
  });
 }

 // ── Event handlers ─────────────────────────────────────

 pi.on("session_start", (_event, ctx) => {
  sessionCtx = ctx;
  fileChanges.clear();
  lastFlushAt = Math.floor(Date.now() / 1000);
  resolveProject(ctx);
  void detectOmpVersion();
  ctx.setInterval(syncAIHeartbeats, AI_SYNC_INTERVAL_MS);
 });

 pi.on("tool_result", async (event, ctx) => {
  if (event.isError) return;
  if (!dedupCall(event.toolCallId)) return;

  const { toolName, input, details } = event;
  const cwd = ctx.cwd || process.cwd();

  interface Change {
   path: string;
   lineDelta: number;
   isWrite: boolean;
  }
  const changes: Change[] = [];
  const push = (path: string | undefined, lineDelta: number, isWrite: boolean) => {
   const entity = path ? normalizeEntity(path, cwd) : undefined;
   if (entity) changes.push({ path: entity, lineDelta, isWrite });
  };

  switch (toolName) {
   case "edit": {
    const d = details as
     | { path?: string; diff?: string; perFileResults?: Array<{ path?: string; diff?: string }> }
     | undefined;
    if (d?.perFileResults) {
     for (const r of d.perFileResults) {
      push(r.path, r.diff ? diffLineChanges(r.diff) : 0, true);
     }
    }
    if (d?.path) push(d.path, d.diff ? diffLineChanges(d.diff) : 0, true);
    if (changes.length === 0) push(getEventPath(input, details), 0, true);
    break;
   }

   case "write": {
    const content = typeof input.content === "string" ? input.content : "";
    push(input.path as string | undefined, contentLineCount(content), true);
    break;
   }

   case "read": {
    const d = details as { isDirectory?: boolean } | undefined;
    if (d?.isDirectory) break;
    push(getEventPath(input, details), 0, false);
    break;
   }

   case "ast_edit": {
    const inputPaths = Array.isArray(input.paths) ? (input.paths as string[]) : [];
    const d = details as
     | { perFileResults?: Array<{ path?: string; diff?: string }> }
     | undefined;
    const byPath = new Map<string, number>();
    if (d?.perFileResults) {
     for (const r of d.perFileResults) {
      if (r.path) byPath.set(r.path, r.diff ? diffLineChanges(r.diff) : 0);
     }
    }
    for (const p of inputPaths) push(p, byPath.get(p) ?? 0, true);
    break;
   }

   default:
    // Only file-touching tools produce entities; grep/glob/task/etc.
    // carry directory or non-file paths that pollute file stats.
    break;
  }

  if (changes.length === 0) return;

  for (const c of changes) {
   trackFile(c.path, c.lineDelta, c.isWrite);
  }

  await flushHeartbeats(false);
 });

 pi.on("session_shutdown", async () => {
  await flushHeartbeats(true);
 });

 // ── Slash command ───────────────────────────────────────

 pi.registerCommand("wakatime", {
  description: "Trigger WakaTime heartbeat manually for current session.",
  handler: async (_args, ctx) => {
   await flushHeartbeats(true);
   ctx.ui.notify?.("WakaTime heartbeat sent.", "info");
  },
 });
}
