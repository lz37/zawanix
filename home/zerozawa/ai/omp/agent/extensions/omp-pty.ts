import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { PtySession } from "@oh-my-pi/pi-natives";
import { z } from "zod";

const DEFAULT_SHELL = "bash";
const DEFAULT_READ_LIMIT = 50;
const MAX_BUFFER_LINES = 50_000;
const MAX_LINE_LENGTH = 2_000;
const DEFAULT_COLS = 120;
const DEFAULT_ROWS = 40;
const SESSION_ID_BYTE_LENGTH = 4;
const NOTIFICATION_LINE_TRUNCATE = 250;

type PtyStatus = "running" | "exited" | "killed";

interface PtySessionState {
  id: string;
  session: PtySession;
  buffer: string[];
  partialLine: string;
  title: string;
  command: string;
  cwd: string;
  status: PtyStatus;
  timeoutSeconds?: number;
  exitCode?: number;
  timedOut?: boolean;
  startTime: number;
  runPromise: Promise<void>;
  lastError?: string;
}

const sessions = new Map<string, PtySessionState>();

function textResult(text: string, isError = false) {
  return {
    content: [{ type: "text" as const, text }],
    ...(isError ? { isError: true } : {}),
  };
}

function messageFromUnknown(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function errorResult(actionZh: string, actionEn: string, error: unknown) {
  return textResult(
    [`错误 / Error: ${actionZh}失败。`, `${actionEn} failed.`, `原因 / Reason: ${messageFromUnknown(error)}`].join("\n"),
    true,
  );
}

function sessionNotFoundResult(id: string) {
  return textResult(
    [`错误 / Error: 找不到 PTY 会话 '${id}'。`, `PTY session '${id}' was not found.`, "请使用 pty_list 查看当前会话 / Use pty_list to see current sessions."].join("\n"),
    true,
  );
}

function generateSessionId(): string {
  const bytes = new Uint8Array(SESSION_ID_BYTE_LENGTH);
  if (typeof crypto !== "undefined" && typeof crypto.getRandomValues === "function") {
    crypto.getRandomValues(bytes);
  } else {
    for (let i = 0; i < bytes.length; i += 1) {
      bytes[i] = Math.floor(Math.random() * 256);
    }
  }

  const hex = Array.from(bytes, byte => byte.toString(16).padStart(2, "0")).join("");
  return `pty_${hex}`;
}

function uniqueSessionId(): string {
  let id = generateSessionId();
  while (sessions.has(id)) {
    id = generateSessionId();
  }
  return id;
}

function quoteShellArg(value: string): string {
  if (value.length === 0) {
    return "''";
  }
  return `'${value.replace(/'/g, `'\\''`)}'`;
}

function buildCommand(command: string, args: string[] = []): string {
  if (args.length === 0) {
    return command;
  }
  return [command, ...args].map(quoteShellArg).join(" ");
}

function displayCommand(command: string, args: string[] = []): string {
  return [command, ...args].filter(part => part.length > 0).join(" ");
}

function buildEnv(extraEnv: Record<string, string> | undefined): Record<string, string> {
  const env: Record<string, string> = {};
  for (const [key, value] of Object.entries(process.env)) {
    if (typeof value === "string") {
      env[key] = value;
    }
  }
  return extraEnv ? { ...env, ...extraEnv } : env;
}

function trimBuffer(state: PtySessionState): void {
  const overflow = state.buffer.length - MAX_BUFFER_LINES;
  if (overflow > 0) {
    state.buffer.splice(0, overflow);
  }
}

function appendOutput(state: PtySessionState, chunk: string): void {
  if (!chunk) {
    return;
  }

  const normalized = `${state.partialLine}${chunk.replace(/\r\n/g, "\n")}`;
  const lines = normalized.split("\n");
  state.partialLine = lines.pop() ?? "";

  if (lines.length > 0) {
    state.buffer.push(...lines);
    trimBuffer(state);
  }
}

function flushPartialLine(state: PtySessionState): void {
  if (state.partialLine.length > 0) {
    state.buffer.push(state.partialLine);
    state.partialLine = "";
    trimBuffer(state);
  }
}

function getBufferedLines(state: PtySessionState): string[] {
  return state.partialLine.length > 0 ? [...state.buffer, state.partialLine] : [...state.buffer];
}

function lineCount(state: PtySessionState): number {
  return state.buffer.length + (state.partialLine.length > 0 ? 1 : 0);
}

function formatLine(line: string, lineNumber: number): string {
  const number = lineNumber.toString().padStart(5, "0");
  const truncated = line.length > MAX_LINE_LENGTH ? `${line.slice(0, MAX_LINE_LENGTH)}...` : line;
  return `${number}| ${truncated}`;
}

function formatAgeSeconds(state: PtySessionState): number {
  return Math.floor((Date.now() - state.startTime) / 1000);
}

export default function(pi: ExtensionAPI) {
  pi.setLabel("OmpPty");
  let teardownStarted = false;


  // Kill all running PTY sessions on session shutdown to prevent ghost processes
  pi.on("session_shutdown", async (_event, _ctx) => {
    teardownStarted = true;
    for (const state of sessions.values()) {
      if (state.status === "running") {
        try {
          state.session.kill();
          state.status = "killed";
        } catch {
          // ignore kill errors during shutdown
        }
      }
    }
    sessions.clear();
  });
  const spawnParamsSchema = z.object({
    command: z.string().min(1).describe("Command or executable to run"),
    args: z.array(z.string()).optional().default([]).describe("Arguments to pass to the command"),
    cwd: z.string().optional().describe("Working directory for the PTY session; defaults to ctx.cwd"),
    env: z.record(z.string(), z.string()).optional().describe("Additional environment variables"),
    title: z.string().optional().describe("Human-readable title for this PTY session"),
    timeoutSeconds: z.number().positive().optional().describe("Optional timeout in seconds"),
    shell: z.string().optional().default(DEFAULT_SHELL).describe("Shell used by the native PTY runner"),
  }).strict();

  const writeParamsSchema = z.object({
    id: z.string().min(1).describe("PTY session ID"),
    data: z.string().describe("Raw data to write to PTY stdin"),
  }).strict();

  const readParamsSchema = z.object({
    id: z.string().min(1).describe("PTY session ID"),
    limit: z.number().int().positive().optional().default(DEFAULT_READ_LIMIT).describe("Number of lines or matches to return"),
    offset: z.number().int().nonnegative().optional().default(0).describe("0-based line or match offset"),
    pattern: z.string().optional().describe("Case-insensitive regex used to filter output lines"),
  }).strict();

  const listParamsSchema = z.object({}).strict();

  const killParamsSchema = z.object({
    id: z.string().min(1).describe("PTY session ID"),
    cleanup: z.boolean().optional().default(false).describe("Remove the session and buffered output after killing"),
  }).strict();

  pi.registerTool<typeof spawnParamsSchema>({
    name: "pty_spawn",
    label: "PTY Spawn",
    description: [
      "Spawns a persistent PTY session in the background and returns immediately.",
      "Use pty_write to send input, pty_read to read buffered output, pty_list to inspect sessions, and pty_kill to terminate one.",
    ].join("\n"),
    parameters: spawnParamsSchema,

    execute: async (toolCallId, params, signal, onUpdate, ctx) => {
      void toolCallId;
      void onUpdate;

      let id: string | undefined;
      try {
        id = uniqueSessionId();
        const pty = new PtySession();
        const args = params.args ?? [];
        const cwd = params.cwd ?? ctx.cwd;
        const command = buildCommand(params.command, args);
        const commandDisplay = displayCommand(params.command, args);
        const title = params.title ?? (commandDisplay.trim() || `Terminal ${id.slice(-4)}`);
        const state: PtySessionState = {
          id,
          session: pty,
          buffer: [],
          partialLine: "",
          title,
          command: commandDisplay,
          cwd,
          status: "running",
          startTime: Date.now(),
          runPromise: Promise.resolve(),
        };
        if (params.timeoutSeconds !== undefined) {
          state.timeoutSeconds = params.timeoutSeconds;
        }

        sessions.set(id, state);

        const startPromise = pty.start(
          {
            command,
            cwd,
            env: buildEnv(params.env),
            timeoutMs: params.timeoutSeconds === undefined ? undefined : params.timeoutSeconds * 1000,
            signal,
            cols: DEFAULT_COLS,
            rows: DEFAULT_ROWS,
            shell: params.shell ?? DEFAULT_SHELL,
          },
          (error, chunk) => {
            if (error) {
              const message = messageFromUnknown(error);
              state.lastError = message;
              appendOutput(state, `\n[PTY 错误 / PTY error] ${message}\n`);
              return;
            }
            appendOutput(state, chunk);
          },
        );

        const notifyExit = () => {
          if (teardownStarted) {
            return;
          }
          const lines = getBufferedLines(state);
          const lastLine = lines.at(-1) ?? "";
          const truncatedLastLine = lastLine.length > NOTIFICATION_LINE_TRUNCATE
            ? `${lastLine.slice(0, NOTIFICATION_LINE_TRUNCATE)}...`
            : lastLine;
          const exitCode = state.exitCode ?? "unknown";
          const timedOut = state.timedOut ?? false;
          const totalLines = lineCount(state);
          const exitDetails = {
            id: state.id,
            title: state.title,
            command: state.command,
            status: state.status,
            exitCode,
            timedOut,
            totalLines,
            lastLine: truncatedLastLine,
          };
          const exitMessage = [
            "<pty_exited>",
            `ID: ${state.id}`,
            `标题 / Title: ${state.title}`,
            `命令 / Command: ${state.command}`,
            `状态 / Status: ${state.status}`,
            `退出码 / ExitCode: ${exitCode}`,
            `超时 / TimedOut: ${timedOut}`,
            `总行数 / TotalLines: ${totalLines}`,
            `最后一行 / LastLine: ${truncatedLastLine}`,
            "</pty_exited>",
          ].join("\n");

          appendOutput(state, `\n${exitMessage}\n`);
          pi.sendMessage(
            {
              customType: "omp-pty-exited",
              content: exitMessage,
              display: true,
              attribution: "agent",
              details: exitDetails,
            },
            { deliverAs: "nextTurn", triggerTurn: true },
          );
          if (ctx.hasUI) {
            try {
              ctx.ui.notify(exitMessage, state.status === "exited" && state.exitCode === 0 ? "info" : "warning");
            } catch {
              // UI notifications are best-effort; the buffer marker is authoritative.
            }
          }
        };

        state.runPromise = startPromise
          .then(result => {
            flushPartialLine(state);
            if (result.exitCode !== undefined) {
              state.exitCode = result.exitCode;
            }
            state.timedOut = result.timedOut;
            if (state.status !== "killed") {
              state.status = result.cancelled || result.timedOut ? "killed" : "exited";
            }
            notifyExit();
          })
          .catch(error => {
            flushPartialLine(state);
            state.lastError = messageFromUnknown(error);
            if (state.status !== "killed") {
              state.status = "exited";
            }
            appendOutput(state, `\n[PTY 启动/运行错误 / PTY start/run error] ${state.lastError}\n`);
            notifyExit();
          });

        return textResult([
          "<pty_spawned>",
          `ID: ${id}`,
          `标题 / Title: ${title}`,
          `命令 / Command: ${commandDisplay}`,
          `目录 / Cwd: ${cwd}`,
          `状态 / Status: running`,
          `Shell: ${params.shell ?? DEFAULT_SHELL}`,
          `超时 / TimeoutSeconds: ${params.timeoutSeconds ?? "none"}`,
          "</pty_spawned>",
        ].join("\n"));
      } catch (error) {
        if (id) {
          sessions.delete(id);
        }
        return errorResult("创建 PTY 会话", "Creating PTY session", error);
      }
    },
  });

  pi.registerTool<typeof writeParamsSchema>({
    name: "pty_write",
    label: "PTY Write",
    description: "Writes raw data to a running PTY session's stdin.",
    parameters: writeParamsSchema,

    execute: async (toolCallId, params, signal, onUpdate, ctx) => {
      void toolCallId;
      void signal;
      void onUpdate;
      void ctx;

      try {
        const state = sessions.get(params.id);
        if (!state) {
          return sessionNotFoundResult(params.id);
        }
        if (state.status !== "running") {
          return textResult(
            [`错误 / Error: PTY 会话 '${params.id}' 不在运行中，不能写入。`, `PTY session '${params.id}' is '${state.status}', so it cannot accept input.`].join("\n"),
            true,
          );
        }

        state.session.write(params.data);
        const byteCount = new TextEncoder().encode(params.data).length;
        return textResult(`已写入 / Wrote ${byteCount} byte(s) to ${params.id}.`);
      } catch (error) {
        return errorResult("写入 PTY 会话", "Writing to PTY session", error);
      }
    },
  });

  pi.registerTool<typeof readParamsSchema>({
    name: "pty_read",
    label: "PTY Read",
    description: "Reads buffered output from a PTY session with pagination and optional case-insensitive regex filtering.",
    parameters: readParamsSchema,

    execute: async (toolCallId, params, signal, onUpdate, ctx) => {
      void toolCallId;
      void signal;
      void onUpdate;
      void ctx;

      try {
        const state = sessions.get(params.id);
        if (!state) {
          return sessionNotFoundResult(params.id);
        }

        const allLines = getBufferedLines(state);
        const offset = params.offset ?? 0;
        const limit = params.limit ?? DEFAULT_READ_LIMIT;
        let selected: Array<{ lineNumber: number; text: string }>;
        let total: number;
        let scope: string;

        if (params.pattern) {
          let regex: RegExp;
          try {
            regex = new RegExp(params.pattern, "i");
          } catch (error) {
            return errorResult("解析正则表达式", "Parsing regex pattern", error);
          }

          const matches = allLines
            .map((text, index) => ({ lineNumber: index + 1, text }))
            .filter(line => regex.test(line.text));
          total = matches.length;
          selected = matches.slice(offset, offset + limit);
          scope = `matches / 匹配 ${total} (total lines / 总行数 ${allLines.length})`;
        } else {
          total = allLines.length;
          selected = allLines.slice(offset, offset + limit).map((text, index) => ({ lineNumber: offset + index + 1, text }));
          scope = `lines / 行 ${total}`;
        }

        const hasMore = offset + selected.length < total;
        const body = selected.length > 0
          ? selected.map(line => formatLine(line.text, line.lineNumber))
          : [params.pattern ? `没有匹配行 / No lines matched pattern '${params.pattern}'.` : "没有输出 / No output available."];

        return textResult([
          `<pty_output id="${params.id}" status="${state.status}"${params.pattern ? ` pattern="${params.pattern}"` : ""}>`,
          ...body,
          "",
          `显示 / Showing: ${selected.length} of ${scope}, offset=${offset}, limit=${limit}`,
          hasMore ? `还有更多 / More available: use offset=${offset + selected.length}.` : "已到末尾 / End of buffer.",
          state.timedOut ? "提醒 / Reminder: this session timed out." : undefined,
          state.lastError ? `最后错误 / Last error: ${state.lastError}` : undefined,
          "</pty_output>",
        ].filter((line): line is string => line !== undefined).join("\n"));
      } catch (error) {
        return errorResult("读取 PTY 输出", "Reading PTY output", error);
      }
    },
  });

  pi.registerTool<typeof listParamsSchema>({
    name: "pty_list",
    label: "PTY List",
    description: "Lists all known PTY sessions and their status.",
    parameters: listParamsSchema,

    execute: async (toolCallId, params, signal, onUpdate, ctx) => {
      void toolCallId;
      void params;
      void signal;
      void onUpdate;
      void ctx;

      try {
        const allSessions = Array.from(sessions.values());
        if (allSessions.length === 0) {
          return textResult("没有 PTY 会话 / No PTY sessions.");
        }

        const lines = ["<pty_list>"];
        for (const state of allSessions) {
          const details = [
            `[${state.id}] ${state.title}`,
            `  状态 / Status: ${state.status}`,
            `  命令 / Command: ${state.command}`,
            `  行数 / LineCount: ${lineCount(state)}`,
            `  已运行 / AgeSeconds: ${formatAgeSeconds(state)}`,
            `  目录 / Cwd: ${state.cwd}`,
          ];
          if (state.exitCode !== undefined) {
            details.push(`  退出码 / ExitCode: ${state.exitCode}`);
          }
          if (state.timedOut !== undefined) {
            details.push(`  超时 / TimedOut: ${state.timedOut}`);
          }
          if (state.lastError) {
            details.push(`  最后错误 / LastError: ${state.lastError}`);
          }
          lines.push(...details, "");
        }
        lines.push(`总计 / Total: ${allSessions.length} session(s)`, "</pty_list>");
        return textResult(lines.join("\n"));
      } catch (error) {
        return errorResult("列出 PTY 会话", "Listing PTY sessions", error);
      }
    },
  });

  pi.registerTool<typeof killParamsSchema>({
    name: "pty_kill",
    label: "PTY Kill",
    description: "Kills a PTY session and optionally removes it from the session map.",
    parameters: killParamsSchema,

    execute: async (toolCallId, params, signal, onUpdate, ctx) => {
      void toolCallId;
      void signal;
      void onUpdate;
      void ctx;

      try {
        const state = sessions.get(params.id);
        if (!state) {
          return sessionNotFoundResult(params.id);
        }

        const wasRunning = state.status === "running";
        if (wasRunning) {
          state.status = "killed";
          state.session.kill();
        }

        const finalLineCount = lineCount(state);
        if (params.cleanup ?? false) {
          state.buffer.length = 0;
          state.partialLine = "";
          sessions.delete(params.id);
        }

        return textResult([
          "<pty_killed>",
          `ID: ${params.id}`,
          `操作 / Action: ${wasRunning ? "killed / 已终止" : "not running / 未在运行"}`,
          `清理 / Cleanup: ${params.cleanup ?? false}`,
          `标题 / Title: ${state.title}`,
          `命令 / Command: ${state.command}`,
          `最终行数 / FinalLineCount: ${finalLineCount}`,
          "</pty_killed>",
        ].join("\n"));
      } catch (error) {
        return errorResult("终止 PTY 会话", "Killing PTY session", error);
      }
    },
  });
}
