import { expect, test } from "bun:test";
import ompPty from "../omp-pty.ts";

type CapturedTool = {
  execute: (...args: unknown[]) => Promise<unknown>;
};
type ShutdownHandler = (...args: unknown[]) => void | Promise<void>;
type SentMessage = { message: unknown; options: unknown };
type ToolContext = {
  cwd: string;
  hasUI: boolean;
  ui: { notify: (message: string, type?: "info" | "warning" | "error") => void };
};

function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null) {
    throw new Error("Expected an object");
  }
  return value as Record<string, unknown>;
}

function requiredString(value: unknown, label: string): string {
  if (typeof value !== "string") {
    throw new Error(`Expected ${label} to be a string`);
  }
  return value;
}

function capturedTool(value: unknown): CapturedTool {
  const record = asRecord(value);
  if (typeof record.execute !== "function") {
    throw new Error("Expected a registered tool execute function");
  }
  return { execute: record.execute as CapturedTool["execute"] };
}

function textResult(value: unknown): string {
  const result = asRecord(value);
  if (!Array.isArray(result.content) || result.content.length === 0) {
    throw new Error("Expected a text tool result");
  }
  const content = asRecord(result.content[0]);
  return requiredString(content.text, "tool result text");
}

test("pty completion is delivered durably and remains readable", async () => {
  const tools = new Map<string, unknown>();
  const sentMessages: SentMessage[] = [];
  let notifyCalls = 0;
  const completion = Promise.withResolvers<SentMessage>();
  let shutdown: ShutdownHandler | undefined;

  const pi = {
    setLabel: (_label: string) => undefined,
    on: (eventName: string, handler: unknown) => {
      if (eventName === "session_shutdown" && typeof handler === "function") {
        shutdown = handler as ShutdownHandler;
      }
    },
    registerTool: (definition: unknown) => {
      const record = asRecord(definition);
      tools.set(requiredString(record.name, "tool name"), definition);
    },
    sendMessage: (message: unknown, options: unknown) => {
      const sent = { message, options };
      sentMessages.push(sent);
      completion.resolve(sent);
    },
  };

  // The fake intentionally supplies only the host wiring exercised by this test.
  ompPty(pi as unknown as Parameters<typeof ompPty>[0]);

  const spawn = capturedTool(tools.get("pty_spawn"));
  const read = capturedTool(tools.get("pty_read"));
  const context: ToolContext = {
    cwd: process.cwd(),
    hasUI: false,
    ui: {
      notify: () => {
        notifyCalls += 1;
        throw new Error("ui.notify must not be called for headless PTY completion");
      },
    },
  };

  try {
    const spawnResult = await spawn.execute(
      "test-pty-spawn",
      { command: "printf done" },
      new AbortController().signal,
      undefined,
      context,
    );
    const spawnText = textResult(spawnResult);
    const idMatch = /ID: (pty_[0-9a-f]+)/.exec(spawnText);
    expect(idMatch).not.toBeNull();
    const id = idMatch?.[1];
    if (!id) {
      throw new Error("PTY spawn did not return a session ID");
    }

    // The native PTY is a real process, so a bounded wall-clock fallback is needed when delivery is absent.
    const sent = await Promise.race([
      completion.promise,
      Bun.sleep(2_000).then(() => {
        throw new Error("Timed out waiting for pty completion delivery");
      }),
    ]);
    expect(sentMessages).toHaveLength(1);

    const message = asRecord(sent.message);
    expect(message.customType).toBe("omp-pty-exited");
    expect(message.display).toBe(true);
    expect(message.attribution).toBe("agent");
    const completionContent = requiredString(message.content, "completion content");
    expect(completionContent).toContain("<pty_exited>");
    expect(completionContent).toContain("done");
    const details = asRecord(message.details);
    expect(details).toMatchObject({ id, command: "printf done", status: "exited", exitCode: 0 });
    expect(details.lastLine).toBe("done");
    expect(sent.options).toEqual({ deliverAs: "nextTurn", triggerTurn: true });
    expect(notifyCalls).toBe(0);
    const readResult = await read.execute(
      "test-pty-read",
      { id, limit: 100 },
      new AbortController().signal,
      undefined,
      context,
    );
    const readText = textResult(readResult);
    expect(readText).toContain("<pty_exited>");
    expect(readText).toContain("done");
  } finally {
    await shutdown?.();
  }
});

test("pty shutdown suppresses completion delivery after native kill", async () => {
  const tools = new Map<string, unknown>();
  const sentMessages: SentMessage[] = [];
  const completion = Promise.withResolvers<SentMessage>();
  let shutdown: ShutdownHandler | undefined;

  const pi = {
    setLabel: (_label: string) => undefined,
    on: (eventName: string, handler: unknown) => {
      if (eventName === "session_shutdown" && typeof handler === "function") {
        shutdown = handler as ShutdownHandler;
      }
    },
    registerTool: (definition: unknown) => {
      const record = asRecord(definition);
      tools.set(requiredString(record.name, "tool name"), definition);
    },
    sendMessage: (message: unknown, options: unknown) => {
      const sent = { message, options };
      sentMessages.push(sent);
      completion.resolve(sent);
    },
  };

  ompPty(pi as unknown as Parameters<typeof ompPty>[0]);

  const spawn = capturedTool(tools.get("pty_spawn"));
  const context: ToolContext = {
    cwd: process.cwd(),
    hasUI: false,
    ui: {
      notify: () => {
        throw new Error("ui.notify must not be called during PTY shutdown");
      },
    },
  };

  try {
    const spawnResult = await spawn.execute(
      "test-pty-shutdown",
      { command: "sleep", args: ["30"] },
      new AbortController().signal,
      undefined,
      context,
    );
    await shutdown?.();
    const spawnText = textResult(spawnResult);
    expect(spawnText).toContain("<pty_spawned>");
    expect(spawnText).toMatch(/ID: pty_[0-9a-f]+/);

    // Native PTY kill completion is asynchronous; use a bounded wall-clock window to catch a late delivery.
    const shutdownOutcome = await Promise.race([
      completion.promise.then(() => "completion-sent" as const),
      Bun.sleep(1_000).then(() => "no-completion" as const),
    ]);
    expect(shutdownOutcome).toBe("no-completion");
    expect(sentMessages).toHaveLength(0);
  } finally {
    await shutdown?.();
  }
});
