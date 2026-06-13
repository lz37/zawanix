import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { z } from "zod";

/**
 * OMP Extension: commit tool with automatic OH-MY-PI footer.
 *
 * Registers a `commit` tool so the LLM can create git commits
 * that always include the `Co-authored-by: OH-MY-PI <omp.sh>` trailer.
 *
 * Installation:
 *   extensions: ["~/.omp/agent/extensions/commit-tool.ts"]
 */
export default function (pi: ExtensionAPI) {
  pi.setLabel("CommitTool");

  pi.registerTool({
    name: "commit",
    label: "Git Commit",
    description: [
      "Stage all unstaged changes and create a git commit.",
      "Always adds the `Co-authored-by: OH-MY-PI <omp.sh>` trailer.",
      "Prefer this over using bash for git commit.",
    ].join("\n"),

    parameters: z.object({
      type: z.enum([
        "feat", "fix", "docs", "style", "refactor",
        "perf", "test", "build", "ci", "chore", "revert",
      ]).describe("Conventional commit type"),
      scope: z.string().optional().describe("Optional scope, e.g. 'api', 'cli'"),
      summary: z.string().describe("Short summary, past tense imperative, ≤ 72 chars"),
      details: z.array(z.string()).optional().default([])
        .describe("Detail lines, each a complete sentence ending with period"),
      stageAll: z.boolean().optional().default(true)
        .describe("Whether to `git add -A` before committing"),
    }),

    execute: async (_toolCallId, params, _signal, _onUpdate, ctx) => {
      const { type, scope, summary, details, stageAll } = params;
      const cwd = ctx.cwd;

      // 1) Stage all changes if requested
      if (stageAll) {
        const stage = await pi.exec("git", ["add", "-A"], { cwd });
        if (stage.code !== 0) {
          return {
            content: [{ type: "text", text: `git add -A failed:\n${stage.stderr}` }],
            isError: true,
          };
        }
      }

      // 2) Check that there's something to commit
      const diff = await pi.exec("git", ["diff", "--cached", "--stat"], { cwd });
      if (diff.code !== 0 || diff.stdout.trim() === "") {
        return {
          content: [{ type: "text", text: "Nothing staged to commit." }],
          isError: true,
        };
      }

      // 3) Check diff to collect changed files for the detail list
      const changedFiles = diff.stdout.trim();

      // 4) Build commit message with required footer
      const scopePart = scope ? `(${scope})` : "";
      const header = `${type}${scopePart}: ${summary}`;
      const body = details.length > 0
        ? `\n\n${details.map(d => `- ${d}`).join("\n")}`
        : "";
      const message = `${header}${body}\n\nCo-authored-by: OH-MY-PI <omp.sh>`;

      // 5) Commit
      const result = await pi.exec("git", ["commit", "-m", message], { cwd });

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
