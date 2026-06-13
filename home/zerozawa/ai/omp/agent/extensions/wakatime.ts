
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/** Minimal process global for type-checking without @types/node. */
declare const process: { cwd(): string; env: Record<string, string | undefined> };

/**
 * WakaTime integration for OMP.
 *
 * Tracks file changes from tool results and sends heartbeats to WakaTime
 * via the wakatime-cli binary. Rate-limited to one batch per 60 seconds.
 *
 * Installation: Add to ~/.omp/agent/config.yml:
 *   extensions: ["~/.omp/agent/extensions/wakatime.ts"]
 *
 * Requires: wakatime-cli on PATH (provided by nixpkgs.wakatime-cli).
 */
export default function (pi: ExtensionAPI) {
  pi.setLabel("WakaTime");

  // ── Constants ──────────────────────────────────────────
  const HEARTBEAT_INTERVAL_S = 60;
  const CLI_WAKATIME = "wakatime-cli";

  // ── State ──────────────────────────────────────────────
  let lastHeartbeatAt = 0;
  const fileChanges = new Map<string, {
    additions: number;
    deletions: number;
    isWrite: boolean;
  }>();
  const seenCallIds = new Set<string>();
  let initialized = false;

  // ── Helpers ────────────────────────────────────────────

  /** Try to determine the project root directory. */
  function getProjectFolder(): string {
    // Prefer explicit OMP cwd from config, then fall back to process.cwd()
    return process.cwd();
  }

  /** Send heartbeats to WakaTime for all tracked file changes (rate-limited). */
  async function flushHeartbeats(force = false): Promise<void> {
    if (fileChanges.size === 0) return;

    const now = Math.floor(Date.now() / 1000);
    if (!force && now - lastHeartbeatAt < HEARTBEAT_INTERVAL_S) return;
    lastHeartbeatAt = now;

    const projectFolder = getProjectFolder();
    const promises: Promise<unknown>[] = [];

    for (const [file, info] of fileChanges.entries()) {
      const args: string[] = [
        "--entity", file,
        "--entity-type", "file",
        "--category", "ai coding",
        "--plugin", "omp-wakatime/1.0.0",
        "--project-folder", projectFolder,
      ];

      const lineDelta = info.additions - info.deletions;
      if (lineDelta !== 0) {
        args.push("--ai-line-changes", String(lineDelta));
      }
      if (info.isWrite) {
        args.push("--write");
      }

      const promise = pi.exec(CLI_WAKATIME, args)
        .then((res) => {
          if (res.code !== 0) {
            pi.logger?.debug?.(
              `[WakaTime] heartbeat failed for ${file}: ${res.stderr?.trim() || res.stdout?.trim()}`,
            );
          }
        })
        .catch(() => {
          // Swallow errors — heartbeat failures should never crash the agent.
        });

      if (force) {
        promises.push(promise);
      }
    }

    fileChanges.clear();

    if (force && promises.length > 0) {
      await Promise.allSettled(promises);
    }
  }

  /** Record a file as changed. */
  function trackFile(
    file: string,
    additions = 0,
    deletions = 0,
    isWrite = true,
  ): void {
    const existing = fileChanges.get(file);
    if (existing) {
      existing.additions += additions;
      existing.deletions += deletions;
      existing.isWrite ||= isWrite;
    } else {
      fileChanges.set(file, { additions, deletions, isWrite });
    }
  }

  /** Deduplicate tool call IDs. Returns false if already seen. */
  function dedupCall(callId: string): boolean {
    if (seenCallIds.has(callId)) return false;
    seenCallIds.add(callId);
    // Trim set when it grows too large
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
  function getEventPath(
    toolName: string,
    input: Record<string, unknown>,
    details: unknown,
  ): string | undefined {
    // Many tools put the path directly in input
    const inputPath = input.path as string | undefined;
    if (inputPath && typeof inputPath === "string") return inputPath;

    // read tool stores resolved path in details
    if (details && typeof details === "object") {
      const d = details as Record<string, unknown>;
      const detailPath = (d.path ?? d.resolvedPath) as string | undefined;
      if (detailPath && typeof detailPath === "string") return detailPath;
    }

    return undefined;
  }

  // ── Event handlers ─────────────────────────────────────

  pi.on("session_start", () => {
    initialized = true;
    fileChanges.clear();
    lastHeartbeatAt = Math.floor(Date.now() / 1000);
  });

  pi.on("tool_result", async (event) => {
    if (event.isError) return;

    // Dedup: tools can emit multiple updates for the same call
    if (!dedupCall(event.toolCallId)) return;

    const { toolName, input, details } = event;
    let paths: string[] = [];

    switch (toolName) {
      case "edit": {
        const d = details as Record<string, unknown> | undefined;
        // Single-file edit
        const singlePath = d?.path as string | undefined;
        if (singlePath) paths.push(singlePath);

        // Multi-file edit (ast_edit style with perFileResults)
        const perFile = d?.perFileResults as
          | Array<{ path?: string }>
          | undefined;
        if (perFile) {
          for (const r of perFile) {
            if (r.path) paths.push(r.path);
          }
        }

        // Fallback: input may have filePath or path
        const inputPath = getEventPath(toolName, input, details);
        if (inputPath && !paths.includes(inputPath)) {
          paths.push(inputPath);
        }
        break;
      }

      case "write": {
        const p = input.path as string | undefined;
        if (p) paths.push(p);
        break;
      }

      case "read": {
        const p = getEventPath(toolName, input, details);
        if (p) paths.push(p);
        break;
      }

      case "ast_edit": {
        // ast_edit takes a paths array
        const inputPaths = input.paths as string[] | undefined;
        if (inputPaths) paths.push(...inputPaths);

        // Also check details for per-file results (shared type with edit)
        const d = details as Record<string, unknown> | undefined;
        const perFile = d?.perFileResults as
          | Array<{ path?: string }>
          | undefined;
        if (perFile) {
          for (const r of perFile) {
            if (r.path) paths.push(r.path);
          }
        }
        break;
      }

      default:
        // For custom/unknown tools, try generic path extraction
        const fallbackPath = getEventPath(toolName, input, details);
        if (fallbackPath) paths.push(fallbackPath);
        break;
    }

    // Deduplicate paths within this event
    paths = [...new Set(paths)];

    if (paths.length === 0) return;

    for (const p of paths) {
      trackFile(p, 0, 0, toolName !== "read");
    }

    // Fire-and-forget heartbeat (rate-limited inside flushHeartbeats)
    await flushHeartbeats(false);
  });

  pi.on("session_shutdown", async () => {
    // Force-send remaining heartbeats before exit
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
