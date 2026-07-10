import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { expect, test } from "bun:test";

type ToolCallHandler = (event: unknown, ctx: unknown) => Promise<unknown>;
type CommandHandler = (args: string, ctx: unknown) => Promise<void>;

test("safety-net can be disabled and re-enabled for the current process", async () => {
 const previousHome = process.env.HOME;
 const temporaryHome = await mkdtemp(join(tmpdir(), "safety-net-test-"));
 process.env.HOME = temporaryHome;

 try {
  // Dynamic import intentionally evaluates the extension after HOME is isolated for its audit log.
  const { default: safetyNet } = await import("../safety-net.ts");
  const createInstance = () => {
   const toolHandlers = new Map<string, ToolCallHandler>();
   const commands = new Map<string, CommandHandler>();
   const notifications: string[] = [];
   const pi = {
    setLabel: (_label: string) => { },
    on: (eventName: string, handler: ToolCallHandler) => {
     toolHandlers.set(eventName, handler);
    },
    registerCommand: (name: string, options: { handler: CommandHandler }) => {
     commands.set(name, options.handler);
    },
   };

   safetyNet(pi as never);
   const toolCall = toolHandlers.get("tool_call");
   const command = commands.get("safety-net");
   expect(toolCall).toBeDefined();
   expect(command).toBeDefined();
   return { command: command!, notifications, toolCall: toolCall! };
  };

  const first = createInstance();
  const firstCommandContext = {
   ui: {
    notify: (message: string) => first.notifications.push(message),
   },
  };

  const expectActiveStatus = (message: string | undefined) => {
   expect(message).toBe(
    "SafetyNet: active — blocking destructive commands. An OMP restart returns safety-net to active.",
   );
  };

  const dangerousEvent = {
   toolName: "bash",
   input: { command: "git stash" },
  };
  const headlessContext = {
   hasUI: false,
   cwd: temporaryHome,
  };

  expect(await first.toolCall(dangerousEvent, headlessContext)).toEqual({
   block: true,
   reason: expect.stringContaining("safety-net blocked"),
  });

  await first.command(" OFF ", firstCommandContext);
  expect(first.notifications.at(-1)).toBe(
   "SafetyNet: inactive — safety checks bypassed. An OMP restart returns safety-net to active.",
  );
  const disabledEvent = {
   toolName: "bash",
   get input(): never {
    throw new Error("event input accessed while safety-net disabled");
   },
  };
  expect(await first.toolCall(disabledEvent, headlessContext)).toBeUndefined();

  const second = createInstance();
  expect(await second.toolCall(dangerousEvent, headlessContext)).toEqual({
   block: true,
   reason: expect.stringContaining("safety-net blocked"),
  });
  expect(await first.toolCall(dangerousEvent, headlessContext)).toBeUndefined();

  await first.command("On", firstCommandContext);
  expectActiveStatus(first.notifications.at(-1));
  expect(await first.toolCall(dangerousEvent, headlessContext)).toEqual({
   block: true,
   reason: expect.stringContaining("safety-net blocked"),
  });

  await first.command("", firstCommandContext);
  expectActiveStatus(first.notifications.at(-1));
  await first.command(" status ", firstCommandContext);
  expectActiveStatus(first.notifications.at(-1));

  await first.command("maybe", firstCommandContext);
  expect(first.notifications.at(-1)).toMatch(/usage/i);
  expect(first.notifications.at(-1)).toMatch(/\/safety-net.*status.*on.*off/i);
 } finally {
  if (previousHome === undefined) delete process.env.HOME;
  else process.env.HOME = previousHome;
  await rm(temporaryHome, { recursive: true, force: true });
 }
});
