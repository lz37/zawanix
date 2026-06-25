/**
 * safety-net: destructive command interceptor for OMP.
 *
 * Replicates cc-safety-net's full feature set as a native OMP extension:
 *   - Semantic git command analysis
 *   - Destructive filesystem command blocking
 *   - Shell wrapper recursion (bash -c / sh -c)
 *   - Interpreter one-liner detection (python -c, node -e, ruby -e, perl -e)
 *   - System-level command guards (sudo, shutdown, mkfs, dd, shred)
 *   - Package removal guards
 *   - Sensitive file access protection (write/edit tools)
 *   - Audit logging to ~/.omp/logs/safety-net-audit.jsonl
 *   - Interactive confirm with ctx.ui.confirm when available
 *   - Fail-closed on hook errors
 */

import type { ExtensionAPI, ToolCallEvent, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

// ─── Types ───────────────────────────────────────────────────────

interface SafetyRule {
 name: string;
 test: (command: string) => string | null; // null = pass, string = reason
}

interface AuditEntry {
 ts: string;
 toolName: string;
 command: string;
 reason: string;
 blocked: boolean;
 cwd: string;
}

// ─── Audit logger ────────────────────────────────────────────────

const AUDIT_LOG = `${process.env.HOME ?? "/root"}/.omp/logs/safety-net-audit.jsonl`;

async function audit(entry: AuditEntry): Promise<void> {
 try {
  const { appendFile } = await import("node:fs/promises");
  await appendFile(AUDIT_LOG, JSON.stringify(entry) + "\n");
 } catch {
  // silent — logging must never block
 }
}

// ─── Helpers ─────────────────────────────────────────────────────

/** Detect shell wrapper: extract inner command from bash -c / sh -c / zsh -c. */
function unwrapShell(cmd: string): string | null {
 const m = /(?:bash|sh|zsh|dash|ksh)\s+-c\s+['"](.+?)['"]\s*$/.exec(cmd);
 if (m) return m[1] ?? null;
 const m2 = /(?:bash|sh|zsh|dash|ksh)\s+-c\s+["](.+?)["]\s*$/.exec(cmd);
 if (m2) return m2[1] ?? null;
 return null;
}

/** Detect interpreter one-liner: python -c / node -e / ruby -e / perl -e. */
function unwrapInterpreter(cmd: string): string | null {
 const m = /(?:python|python3)\s+-c\s+['"](.+?)['"]/.exec(cmd);
 if (m) return m[1] ?? null;
 const m2 = /(?:node|bun)\s+(?:-e|--eval)\s+['"](.+?)['"]/.exec(cmd);
 if (m2) return m2[1] ?? null;
 const m3 = /ruby\s+-e\s+['"](.+?)['"]/.exec(cmd);
 if (m3) return m3[1] ?? null;
 const m4 = /perl\s+-e\s+['"](.+?)['"]/.exec(cmd);
 if (m4) return m4[1] ?? null;
 return null;
}

/** Recursively unwrap nested shells up to depth limit. Max depth 10. */
function recursiveUnwrap(cmd: string, depth = 0): string {
 if (depth >= 10) return cmd;
 const inner = unwrapShell(cmd) || unwrapInterpreter(cmd);
 if (inner) return recursiveUnwrap(inner, depth + 1);
 return cmd;
}

// ─── Git safety rules ────────────────────────────────────────────

const gitRules: SafetyRule[] = [
 {
  name: "git-stash",
  test: (c) =>
   /git\s+stash\b/.test(c)
    ? "`git stash` is blocked by safety policy"
    : null,
 },
 {
  name: "git-checkout",
  test: (c) =>
   /git\s+checkout\b/.test(c)
    ? "`git checkout` is blocked by safety policy"
    : null,
 },
 {
  name: "git-reset-hard",
  test: (c) =>
   /git\s+reset\s+--hard\b/.test(c)
    ? "`git reset --hard` discards uncommitted changes permanently"
    : null,
 },
 {
  name: "git-push-force",
  test: (c) =>
   /git\s+push\s+.*--force\b/.test(c)
    ? "`git push --force` overwrites remote history"
    : null,
 },
 {
  name: "git-stash-clear",
  test: (c) => /git\s+stash\s+clear\b/.test(c) ? "`git stash clear` deletes all stashes" : null,
 },
 {
  name: "git-stash-drop",
  test: (c) => /git\s+stash\s+drop\b/.test(c) ? "`git stash drop` deletes a stash" : null,
 },
 {
  name: "git-clean",
  test: (c) =>
   /git\s+clean\s+.*-f(?:d)?/.test(c)
    ? "`git clean -fd` deletes untracked files and directories"
    : null,
 },
 {
  name: "git-rebase",
  test: (c) =>
   /git\s+rebase\s+--(?:interactive|exec|onto)\b/.test(c)
    ? "`git rebase` rewrites commit history"
    : null,
 },
 {
  name: "git-commit-amend",
  test: (c) =>
   /git\s+commit\s+--amend\b/.test(c)
    ? "`git commit --amend` modifies the last commit"
    : null,
 },
 {
  name: "git-update-ref",
  test: (c) => /git\s+update-ref\b/.test(c) ? "`git update-ref` can corrupt references" : null,
 },
 {
  name: "git-branch-delete",
  test: (c) =>
   /git\s+branch\s+--delete\b|\sgit\s+branch\s+-d\b/.test(c)
    ? "`git branch -d` deletes a branch"
    : null,
 },
];

// ─── Filesystem destructive rules ────────────────────────────────

const FS_DANGER_PATHS = [
 "^\\s*/\\s*$",
 "^\\s*/root",
 "^\\s*/home",
 "^\\s*/etc",
 "^\\s*/nix",
 "^\\s*/usr",
 "^\\s*/var",
 "^\\s*/boot",
 "^\\s*/bin",
 "^\\s*/sbin",
 "^\\s*/lib",
 "^\\s*/opt",
 "^\\s*/dev",
 "^\\s*/proc",
 "^\\s*/sys",
 "^\\s*/run",
 "^\\s*/tmp\\s",
];

const fsRules: SafetyRule[] = [
 {
  name: "rm-root",
  test: (c) => {
   if (!/\brm\b/.test(c)) return null;
   const target = c.replace(/.*\brm\s*(?:-[-rfv]*\s+)*/, "").trim();
   const isDanger = FS_DANGER_PATHS.some((p) => new RegExp(p).test(target));
   if (isDanger) return `rm targets critical system path: ${target.slice(0, 80)}`;
   return null;
  },
 },
 {
  name: "find-delete",
  test: (c) =>
   /\bfind\b.*\s+-delete\b/.test(c) || /\bfind\b.*-exec\s+rm\b/.test(c)
    ? "`find -delete` / `find -exec rm` bulk-deletes files"
    : null,
 },
 {
  name: "shred",
  test: (c) => /\bshred\b/.test(c) ? "`shred` permanently deletes files" : null,
 },
 {
  name: "dd",
  test: (c) =>
   /\bdd\b/.test(c) && /\bof=/.test(c) && !c.includes("of=/dev/null")
    ? "`dd` can overwrite disks and partitions"
    : null,
 },
 {
  name: "mkfs",
  test: (c) =>
   /\bmkfs\b|\bmkfs\.\w+\b/.test(c) ? "`mkfs` formats a filesystem, destroying all data" : null,
 },
 {
  name: "wipefs",
  test: (c) => /\bwipefs\b/.test(c) ? "`wipefs` wipes filesystem signatures" : null,
 },
 {
  name: "fdisk-partition",
  test: (c) => /\bfdisk\b/.test(c) ? "`fdisk` modifies partition tables" : null,
 },
 {
  name: "truncate-file",
  test: (c) =>
   /\btruncate\s+-s\s+0\b/.test(c) ? "`truncate -s 0` empties a file" : null,
 },
 {
  name: "chmod-recursive",
  test: (c) =>
   /\bchmod\s+.*-R\b/.test(c) ? "recursive `chmod -R` can break system permissions" : null,
 },
 {
  name: "chown-recursive",
  test: (c) =>
   /\bchown\s+.*-R\b/.test(c) ? "recursive `chown -R` can break system ownership" : null,
 },
 {
  name: "ln-force",
  test: (c) => /\bln\s+.*-f\b/.test(c) ? "`ln -f` force-overwrites existing files" : null,
 },
 {
  name: "mv-force",
  test: (c) =>
   /\bmv\s+.*-f\b/.test(c) ? "`mv -f` force-overwrites without confirmation" : null,
 },
 {
  name: "cp-force-recursive",
  test: (c) =>
   /\bcp\s+.*-r(?:ecursive)?.*\s+\//.test(c)
    ? "recursive copy to / can overwrite system files"
    : null,
 },
];

// ─── System-level safety rules ───────────────────────────────────

const systemRules: SafetyRule[] = [
 {
  name: "sudo-destructive",
  test: (c) => {
   if (!/\bsudo\b/.test(c)) return null;
   const rest = c.replace(/\bsudo\s+/, "");
   if (
    /\brm\b/.test(rest) || /\bshutdown\b/.test(rest) || /\breboot\b/.test(rest) ||
    /\bmkfs\b/.test(rest) || /\bdd\b/.test(rest) || /\bshred\b/.test(rest) ||
    /\bpoweroff\b/.test(rest) || /\bhalt\b/.test(rest) ||
    /\bsystemctl\s+(?:stop|disable|restart|kill)\b/.test(rest) ||
    /\bpacman\s+-R\b/.test(rest) || /\bapt\s+(?:remove|purge)\b/.test(rest)
   ) {
    return `sudo with destructive command: ${rest.slice(0, 80)}`;
   }
   return null;
  },
 },
 {
  name: "shutdown-reboot",
  test: (c) =>
   /\bshutdown\b|\breboot\b|\bpoweroff\b|\bhalt\b/.test(c)
    ? "system shutdown / reboot command"
    : null,
 },
 {
  name: "systemctl-stop",
  test: (c) =>
   /\bsystemctl\s+(?:stop|disable|restart|kill|mask)\b/.test(c)
    ? "`systemctl stop/disable/restart` changes system services"
    : null,
 },
 {
  name: "journalctl-rotate",
  test: (c) =>
   /\bjournalctl\s+--rotate\b|\bjournalctl\s+--vacuum\b/.test(c)
    ? "`journalctl --rotate/--vacuum` modifies system logs"
    : null,
 },
];

// ─── Process safety rules ────────────────────────────────────────

const processRules: SafetyRule[] = [
 {
  name: "kill-9",
  test: (c) =>
   /\bkill\s+-9\b|\bkill\s+-SIGKILL\b/.test(c)
    ? "`kill -9` force-kills a process without cleanup"
    : null,
 },
 {
  name: "pkill",
  test: (c) => /\bpkill\b|\bkillall\b/.test(c) ? "`pkill`/`killall` bulk-kills processes" : null,
 },
];

// ─── Package removal rules ───────────────────────────────────────

const packageRules: SafetyRule[] = [
 {
  name: "npm-uninstall",
  test: (c) =>
   /\bnpm\s+uninstall\b|\bnpm\s+remove\b|\bnpm\s+rm\b|\bnpm\s+un\b/.test(c)
    ? "`npm uninstall` removes a package"
    : null,
 },
 {
  name: "pip-uninstall",
  test: (c) => /\bpip\s+uninstall\b|\bpip3\s+uninstall\b/.test(c) ? "`pip uninstall` removes a package" : null,
 },
 {
  name: "apt-remove",
  test: (c) =>
   /\bapt\s+(?:remove|purge)\b|\bapt-get\s+(?:remove|purge)\b/.test(c)
    ? "`apt remove/purge` removes system packages"
    : null,
 },
 {
  name: "pacman-remove",
  test: (c) =>
   /\bpacman\s+-R\b|\bpacman\s+--remove\b/.test(c)
    ? "`pacman -R` removes packages"
    : null,
 },
 {
  name: "pnpm-remove",
  test: (c) => /\bpnpm\s+remove\b|\bpnpm\s+rm\b|\bpnpm\s+uninstall\b/.test(c) ? "`pnpm remove` removes a package" : null,
 },
 {
  name: "nix-collect-garbage",
  test: (c) =>
   /\bnix-collect-garbage\b|\bnix\s+store\s+--delete\b/.test(c)
    ? "nix garbage collection / store delete is destructive"
    : null,
 },
 {
  name: "nixos-rebuild-switch",
  test: (c) =>
   /\bnixos-rebuild\s+switch\b/.test(c)
    ? "`nixos-rebuild switch` changes system configuration"
    : null,
 },
];

// ─── SQL safety rules ────────────────────────────────────────────

const sqlRules: SafetyRule[] = [
 {
  name: "sql-drop-database",
  test: (c) => /\bDROP\s+DATABASE\b/i.test(c) ? "`DROP DATABASE` deletes an entire database" : null,
 },
 {
  name: "sql-drop-table",
  test: (c) => /\bDROP\s+TABLE\b/i.test(c) ? "`DROP TABLE` deletes a table" : null,
 },
 {
  name: "sql-truncate",
  test: (c) => /\bTRUNCATE\b/i.test(c) ? "`TRUNCATE` deletes all rows from a table" : null,
 },
 {
  name: "sql-delete-no-where",
  test: (c) => {
   if (!/\bDELETE\s+FROM\b/i.test(c)) return null;
   if (/\bWHERE\b/i.test(c)) return null;
   return "`DELETE FROM` without WHERE deletes all rows";
  },
 },
 {
  name: "sql-update-no-where",
  test: (c) => {
   if (!/\bUPDATE\b/i.test(c)) return null;
   if (/\bWHERE\b/i.test(c)) return null;
   return "`UPDATE` without WHERE modifies all rows";
  },
 },
];

// ─── All rules ───────────────────────────────────────────────────

const ALL_RULES: SafetyRule[] = [
 ...gitRules,
 ...fsRules,
 ...systemRules,
 ...processRules,
 ...packageRules,
 ...sqlRules,
];

// ─── Sensitive file paths ────────────────────────────────────────

const SENSITIVE_FILE_PATTERNS = [
 ".env",
 ".env.*",
 ".npmrc",
 ".pypirc",
 ".netrc",
 ".aws/credentials",
 ".aws/config",
 ".azure/credentials",
 ".kube/config",
 "**/id_rsa",
 "**/id_ed25519",
 "**/id_ecdsa",
 "**/id_dsa",
 "**/*.pem",
 "**/*.key",
 "**/*.p12",
 "**/*.pfx",
 "**/*.kdbx",
 "**/*.kdb",
 "**/ secrets.yml",
 "**/ secrets.yaml",
 "**/ secrets.json",
 "**/.config/gcloud/application_default_credentials.json",
 "**/.config/gh/hosts.yml",
 "**/.docker/config.json",
 "**/.omp/agent/agent.db*",
 "**/.omp/logs/*",
];

function isSensitiveFile(filePath: string): string | null {
 const lower = filePath.toLowerCase();
 for (const pattern of SENSITIVE_FILE_PATTERNS) {
  const escaped = pattern
   .replace(/[.+^${}()|[\]\\]/g, "\\$&")
   .replace(/\*\*/g, ".*")
   .replace(/\*/g, "[^/]*");
  if (new RegExp(escaped, "i").test(lower)) {
   return `sensitive file access blocked: ${pattern}`;
  }
 }
 return null;
}

// ─── Blocking logic ──────────────────────────────────────────────

function checkBashCommand(command: string): string | null {
 if (!command) return null;

 const resolved = recursiveUnwrap(command);

 // Recursively check inner command if unwrapped
 if (resolved !== command) {
  const innerReason = checkBashCommand(resolved);
  if (innerReason) return `shell wrapper detected: ${innerReason}`;
 }

 for (const rule of ALL_RULES) {
  const reason = rule.test(resolved);
  if (reason) return reason;
 }

 return null;
}

function checkFilePath(_toolName: string, input: Record<string, unknown>): string | null {
 const path = (input.path as string) ?? (input.file as string) ?? "";
 if (!path) return null;

 const sensitiveReason = isSensitiveFile(path);
 if (sensitiveReason) return sensitiveReason;

 const lowerPath = path.toLowerCase();
 const CRITICAL_PATHS = [
  "/etc/sudoers",
  "/etc/passwd",
  "/etc/shadow",
  "/etc/ssh/",
  "/boot/",
  "/nix/store/",
 ];
 for (const cp of CRITICAL_PATHS) {
  if (lowerPath.includes(cp)) {
   return `writing to critical system path: ${cp}`;
  }
 }

 return null;
}

// ─── Interactive confirm ─────────────────────────────────────────

async function maybeBlock(
 ctx: ExtensionContext,
 reason: string,
 command: string,
): Promise<{ block: boolean; reason: string } | undefined> {
 if (!ctx.hasUI) {
  return { block: true, reason: `safety-net blocked: ${reason}` };
 }

 const allowed = await ctx.ui.confirm("Dangerous operation detected", `${reason}\n\nCommand: ${command}\n\nAllow?`);
 if (!allowed) {
  return { block: true, reason: `safety-net blocked: ${reason}` };
 }
 return undefined; // allow
}

// ─── Extension entry point ───────────────────────────────────────

export default function safetyNet(pi: ExtensionAPI) {
 pi.setLabel("SafetyNet");

 pi.on("tool_call", async (event: ToolCallEvent, ctx: ExtensionContext) => {
  try {
   if (event.toolName === "bash" || event.toolName === "direnv_shell") {
    const input = event.input as { command?: unknown; cwd?: unknown };
    const command = String(input.command ?? "");

    const reason = checkBashCommand(command);
    if (reason) {
     const result = await maybeBlock(ctx, reason, command);
     if (result) {
      await audit({
       ts: new Date().toISOString(),
       toolName: event.toolName,
       command: command.slice(0, 500),
       reason,
       blocked: true,
       cwd: ctx.cwd,
      });
     }
     return result;
    }
   }

   if (event.toolName === "write" || event.toolName === "edit") {
    const input = event.input as Record<string, unknown>;
    const reason = checkFilePath(event.toolName, input);
    if (reason) {
     const path = (input.path as string) ?? (input.file as string) ?? "?";
     const result = await maybeBlock(ctx, reason, path);
     if (result) {
      await audit({
       ts: new Date().toISOString(),
       toolName: event.toolName,
       command: path,
       reason,
       blocked: true,
       cwd: ctx.cwd,
      });
     }
     return result;
    }
   }
  } catch (err) {
   // Fail-closed: if our handler throws, block the tool
   const msg = err instanceof Error ? err.message : String(err);
   return { block: true, reason: `safety-net internal error (fail-closed): ${msg}` };
  }
 });

 // ─── Slash command: /safety-net ──────────────────────────────
 pi.registerCommand("safety-net", {
  description: "Show safety-net status and stats",
  handler: async (_args, cmdCtx) => {
   cmdCtx.ui.notify("SafetyNet: active — blocking destructive commands", "info");
  },
 });
}
