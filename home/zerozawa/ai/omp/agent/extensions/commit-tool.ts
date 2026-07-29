import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import * as path from "node:path";
import { z } from "zod";

/**
 * OMP Extension: multi-stage commit tool with automatic OH-MY-PI footer.
 *
 * Supports both single-commit (backward compatible) and multi-stage commit
 * modes. In multi-stage mode, each stage commits a subset of files with its
 * own conventional commit message, enabling logical separation of changes.
 *
 * Installation:
 *   extensions: ["~/.omp/agent/extensions/commit-tool.ts"]
 */
export default function(pi: ExtensionAPI) {
 pi.setLabel("CommitTool");

 // ── Shared schemas ────────────────────────────────────

 const commitType = z.enum([
  "feat", "fix", "docs", "style", "refactor",
  "perf", "test", "build", "ci", "chore", "revert",
 ]);

 const bodySchema = z.union([z.string(), z.array(z.string())])
  .optional()
  .describe(
   "Long-form body: prose paragraph(s) explaining the why and what, rendered between the header and bullet details (paragraphs separated by blank lines). Pass a string (may contain \n\n) or an array of paragraphs.",
  );

 const stageSchema = z.object({
  files: z.union([
   z.array(z.string()).describe(
    "File paths (relative to repo root) to include in this commit stage",
   ),
   z.literal("all").describe(
    "Stage all remaining (not yet committed) changed files",
   ),
  ]).describe("Files to include in this commit"),
  type: commitType.describe("Conventional commit type"),
  scope: z.string().optional().describe("Optional scope, e.g. 'api', 'cli'"),
  summary: z.string().describe("Short summary, past tense imperative, ≤ 72 chars"),
  body: bodySchema,
  details: z.array(z.string()).optional().default([])
   .describe("Bullet lines after the body, e.g. per-file change notes ('client.rs: capture request_id ...'). Each a complete sentence ending with period"),
 });


 const paramsSchema = z.object({
  // Target repository
  path: z.string().optional().describe(
   "Repository directory to commit in. Defaults to the current working directory; '~' and relative paths resolve against it. Use this to commit in repos outside the session cwd.",
  ),
  // Single-commit mode
  type: commitType.optional().describe("Conventional commit type (single-commit mode)"),
  scope: z.string().optional().describe("Optional scope, e.g. 'api', 'cli'"),
  summary: z.string().optional().describe("Short summary, past tense imperative, ≤ 72 chars"),
  body: bodySchema,
  details: z.array(z.string()).optional().default([])
   .describe("Bullet lines after the body, e.g. per-file change notes. Each a complete sentence ending with period"),
  stageAll: z.boolean().optional().default(true)
   .describe("Whether to `git add -A` before committing"),
  // Multi-stage mode
  stages: z.array(stageSchema).min(1)
   .optional()
   .describe("Multi-stage: each stage commits a subset with its own message"),
 });

 type CommitParams = z.infer<typeof paramsSchema>;

 // ── Tool registration ─────────────────────────────────

 pi.registerTool<z.ZodType<CommitParams>>({
  name: "commit",
  label: "Git Commit (Multi-Stage)",
  description: [
   "Stage and commit changes in a git repository (`path` defaults to session cwd; use it for repos elsewhere). Supports single-stage (`type`+`summary`) and multi-stage (`stages` array) modes.",
   "Message format: `type(scope): summary` header, optional `body` prose paragraphs, then `details` bullet lines.",
   "Always adds the `Co-authored-by: OH-MY-PI <omp@can.ac>` trailer.",
  ].join("\n"),
  parameters: paramsSchema,
  loadMode: "essential" as const,

  execute: async (_toolCallId, params, _signal, _onUpdate, ctx) => {
   const cwd = resolveCwd(params.path, ctx.cwd);

   // ── Helpers ──────────────────────────────────────────

   /** Resolve the repo dir: explicit path > session cwd; '~' and relative paths resolve against session cwd. */
   function resolveCwd(input: string | undefined, fallback: string): string {
    const raw = input?.trim();
    if (!raw) return fallback;
    let p = raw;
    const home = process.env.HOME;
    if (p === "~" && home) p = home;
    else if (p.startsWith("~/") && home) p = `${home}${p.slice(1)}`;
    return path.isAbsolute(p) ? path.normalize(p) : path.resolve(fallback, p);
   }

   /** Normalize body input into a list of non-empty paragraphs. */
   function toParagraphs(body: string | string[] | undefined): string[] {
    if (!body) return [];
    const list = Array.isArray(body) ? body : [body];
    return list.map(p => p.trim()).filter(Boolean);
   }

   /** Build a conventional commit message with OH-MY-PI footer. */
   function buildMessage(
    type: string,
    scope: string | undefined,
    summary: string,
    body: string | string[] | undefined,
    details: string[],
   ): string {
    const scopePart = scope ? `(${scope})` : "";
    const sections = [`${type}${scopePart}: ${summary}`];
    const paragraphs = toParagraphs(body);
    if (paragraphs.length > 0) sections.push(paragraphs.join("\n\n"));
    if (details.length > 0) sections.push(details.map(d => `- ${d}`).join("\n"));
    return `${sections.join("\n\n")}\n\nCo-authored-by: OH-MY-PI <omp@can.ac>`;
   }

   /** Run a git command and return { code, stdout, stderr }. */
   async function git(args: string[]): Promise<{
    code: number;
    stdout: string;
    stderr: string;
   }> {
    return pi.exec("git", args, { cwd });
   }

   /** Collect all changed files (staged + unstaged + untracked). */
   async function collectAllChanged(): Promise<Set<string>> {
    // `-z` disables core.quotePath C-style quoting (which octal-escapes
    // non-ASCII/CJK paths) and NUL-separates entries, so filenames with
    // whitespace or newlines survive intact.
    const [stagedRaw, unstagedRaw, untrackedRaw] = await Promise.all([
     git(["diff", "--cached", "--name-only", "-z"]),
     git(["diff", "--name-only", "-z"]),
     git(["ls-files", "--others", "--exclude-standard", "-z"]),
    ]);

    const files = new Set<string>();
    for (const raw of [stagedRaw.stdout, unstagedRaw.stdout, untrackedRaw.stdout]) {
     for (const name of raw.split("\0")) {
      if (name) files.add(name);
     }
    }
    return files;
   }


   // ── Normalize: single-stage → one-element stages array ──
   const repoCheck = await git(["rev-parse", "--show-toplevel"]);
   if (repoCheck.code !== 0) {
    return {
     content: [{ type: "text", text: `Not a git repository: ${cwd}\n${repoCheck.stderr.trim()}` }],
     isError: true,
    };
   }

   if (!params.stages) {
    if (!params.type || !params.summary) {
     return {
      content: [{ type: "text", text: "Either `stages` array or `type`+`summary` is required." }],
      isError: true,
     };
    }
    // stageAll: false → commit only what's already staged (no reset, no add)
    if (params.stageAll === false) {
     const message = buildMessage(params.type, params.scope, params.summary, params.body, params.details || []);
     const result = await git(["commit", "-m", message]);
     if (result.code !== 0) {
      return {
       content: [{ type: "text", text: `git commit failed: ${result.stderr}` }],
       isError: true,
      };
     }
     return {
      content: [{ type: "text", text: result.stdout.trim() || result.stderr.trim() }],
      isError: false,
     };
    }
    params.stages = [{
     files: "all" as const,
     type: params.type,
     scope: params.scope,
     summary: params.summary,
     body: params.body,
     details: params.details || [],
    }];
   }

   const stages = params.stages;

   // 1) Snapshot all current changes
   const allChanged = await collectAllChanged();
   if (allChanged.size === 0) {
    return {
     content: [{ type: "text", text: "No changes detected in the working tree." }],
     isError: true,
    };
   }

   // 2) Clear any pre-staged changes so stages start clean
   await git(["reset"]);

   // 3) Process each stage
   const consumed = new Set<string>();
   const log: string[] = [];
   let hadFailure = false;

   for (const [i, stage] of stages.entries()) {
    const tag = `Stage ${i + 1}/${stages.length} (${stage.type}${stage.scope ? `(${stage.scope})` : ""}: ${stage.summary})`;

    // Resolve fileset
    let candidates: string[];
    if (stage.files === "all") {
     candidates = Array.from(allChanged).filter(f => !consumed.has(f));
    } else {
     candidates = stage.files;
    }

    // Filter to what's actually changed and not yet consumed
    const available = candidates.filter(f => allChanged.has(f) && !consumed.has(f));

    if (available.length === 0) {
     log.push(`⚠️  ${tag}: no available files to commit. Skipping.`);
     continue;
    }

    // Stage
    const addResult = await git(["add", "--", ...available]);
    if (addResult.code !== 0) {
     log.push(`❌ ${tag}: git add failed:\n${addResult.stderr}`);
     hadFailure = true;
     continue;
    }

    // Verify staged
    const check = await git(["diff", "--cached", "--stat"]);
    if (check.code !== 0 || check.stdout.trim() === "") {
     log.push(`⚠️  ${tag}: nothing staged (possibly filtered by .gitignore or hooks). Skipping.`);
     continue;
    }

    // Commit
    const message = buildMessage(
     stage.type,
     stage.scope,
     stage.summary,
     stage.body,
     stage.details ?? [],
    );
    const commitResult = await git(["commit", "-m", message]);
    if (commitResult.code !== 0) {
     log.push(`❌ ${tag}: git commit failed (exit ${commitResult.code}):\n${commitResult.stderr}`);
     hadFailure = true;
     continue;
    }

    available.forEach(f => consumed.add(f));
    log.push(`✅ ${tag}\n   Files: ${available.join(", ")}\n   ${commitResult.stdout.trim()}`);
   }

   // Remaining unconsumed files
   const leftover = Array.from(allChanged).filter(f => !consumed.has(f));
   if (leftover.length > 0) {
    log.push(`\n⚠️  Uncommitted files remaining (not covered by any stage):\n   ${leftover.join("\n   ")}`);
   }

   return {
    content: [{ type: "text", text: log.join("\n\n") }],
    isError: hadFailure,
   };
  },
 });
}
