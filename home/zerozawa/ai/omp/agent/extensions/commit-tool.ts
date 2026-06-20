import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
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
export default function (pi: ExtensionAPI) {
  pi.setLabel("CommitTool");

  // ── Shared schemas ────────────────────────────────────

  const commitType = z.enum([
    "feat", "fix", "docs", "style", "refactor",
    "perf", "test", "build", "ci", "chore", "revert",
  ]);

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
    details: z.array(z.string()).optional().default([])
      .describe("Detail lines, each a complete sentence ending with period"),
  });


  const paramsSchema = z.object({
    // Single-commit mode
    type: commitType.optional().describe("Conventional commit type (single-commit mode)"),
    scope: z.string().optional().describe("Optional scope, e.g. 'api', 'cli'"),
    summary: z.string().optional().describe("Short summary, past tense imperative, ≤ 72 chars"),
    details: z.array(z.string()).optional().default([])
      .describe("Detail lines, each a complete sentence ending with period"),
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
      "Stage and commit changes. Supports single commits (backward compatible)",
      "or multi-stage commits where different file groups get separate commits.",
      "Always adds the `Co-authored-by: OH-MY-PI <omp.sh>` trailer.",
      "",
      "Single-commit mode: provide `type` + `summary` (optionally `scope`, `details`, `stageAll`).",
      "Multi-stage mode: provide `stages` array, each with `files`, `type`, `summary`.",
    ].join("\n"),

    parameters: paramsSchema,

    execute: async (_toolCallId, params, _signal, _onUpdate, ctx) => {
      const cwd = ctx.cwd;

      // ── Helpers ──────────────────────────────────────────

      /** Build a conventional commit message with OH-MY-PI footer. */
      function buildMessage(
        type: string,
        scope: string | undefined,
        summary: string,
        details: string[],
      ): string {
        const scopePart = scope ? `(${scope})` : "";
        const header = `${type}${scopePart}: ${summary}`;
        const body = details.length > 0
          ? `\n\n${details.map(d => `- ${d}`).join("\n")}`
          : "";
        return `${header}${body}\n\nCo-authored-by: OH-MY-PI <omp.sh>`;
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
        const [stagedRaw, unstagedRaw, untrackedRaw] = await Promise.all([
          git(["diff", "--cached", "--name-only"]),
          git(["diff", "--name-only"]),
          git(["ls-files", "--others", "--exclude-standard"]),
        ]);

        const files = new Set<string>();
        for (const raw of [stagedRaw.stdout, unstagedRaw.stdout, untrackedRaw.stdout]) {
          for (const line of raw.split("\n")) {
            const trimmed = line.trim();
            if (trimmed) files.add(trimmed);
          }
        }
        return files;
      }

      // ================================================================
      // MULTI-STAGE MODE
      // ================================================================
      if (params.stages) {
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
      }

      // ================================================================
      // SINGLE-COMMIT MODE (backward compatible)
      // ================================================================
      const { type, scope, summary, details, stageAll } = params;

      if (!type || !summary) {
        return {
          content: [{ type: "text", text: "Single-commit mode requires `type` and `summary`." }],
          isError: true,
        };
      }

      // 2) Check that there's something to commit
      const diff = await git(["diff", "--cached", "--stat"]);
      if (diff.code !== 0 || diff.stdout.trim() === "") {
        return {
          content: [{ type: "text", text: "Nothing staged to commit." }],
          isError: true,
        };
      }

      const changedFiles = diff.stdout.trim();

      // 3) Build and commit
      const message = buildMessage(type, scope, summary, details);
      const result = await git(["commit", "-m", message]);
      if (result.code !== 0) {
        return {
          content: [{
            type: "text",
            text: `git commit failed (exit ${result.code}):\n${result.stderr}`,
          }],
          isError: true,
        };
      }

      return {
        content: [{
          type: "text",
          text: [
            `✅ Committed:\n${message}`,
            changedFiles,
            result.stdout.trim(),
          ].join("\n\n"),
        }],
      };
    },
  });
}
