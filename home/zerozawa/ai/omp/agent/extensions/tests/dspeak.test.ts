import { expect, test } from "bun:test";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { cfgModelRoles } from "@oh-my-pi/pi-coding-agent/config/model-settings";
import { Settings } from "@oh-my-pi/pi-coding-agent/config/settings";
import { cfgTaskAgentModelOverrides } from "@oh-my-pi/pi-coding-agent/task/settings";
import dspeak from "../dspeak";

test("peak pin falls back on depleted quota, recovers, and never persists resolved selectors", async () => {
 const peak = "openai-codex/gpt-5.6-luna:max";
 const offpeak = "litellm/deepseek-v4-flash:max";
 const selector = `dspeak/peak=${peak}&default=${offpeak}`;
 const settings = Settings.isolated();
 const roles = { smol: selector, task: selector, default: "manual/model" };
 const agents = { scout: [selector, "manual/model"] };
 cfgModelRoles.set(settings, roles);
 cfgTaskAgentModelOverrides.set(settings, agents);
 const handlers = new Map<string, (event: unknown, ctx: ExtensionContext) => unknown>();
 let command!: (args: string, ctx: ExtensionContext) => Promise<void>;
 let quota: "healthy" | "depleted" = "healthy";
 const branch = [{ type: "custom", customType: "dspeak.pin", data: { mode: "peak" } }];
 const ctx = {
  hasUI: false,
  ui: { notify() { } },
  models: { resolve: (spec: string) => [peak, offpeak].includes(spec) ? { id: spec } : undefined },
  modelRegistry: {
   getProviderBaseUrl: () => undefined,
   authStorage: { health: { model: async () => ({ state: quota, accounts: [] }) } },
  },
  sessionManager: { getSessionId: () => "dspeak-regression", getBranch: () => branch },
  setInterval() { },
 } as unknown as ExtensionContext;
 dspeak({
  pi: { settings },
  setLabel() { },
  on: (name: string, handler: (event: unknown, ctx: ExtensionContext) => unknown) => handlers.set(name, handler),
  appendEntry: (customType: string, data: { mode: string }) => branch.push({ type: "custom", customType, data }),
  registerCommand: (_name: string, definition: { handler: typeof command }) => { command = definition.handler; },
 } as unknown as ExtensionAPI);

 try {
  await handlers.get("session_start")!({}, ctx);
  expect(settings.getModelRole("smol")).toBe(peak); // Resume restores the recorded pin, not today's mode.
  await command("peak", ctx);
  expect(settings.getModelRole("task")).toBe(peak);
  expect(cfgTaskAgentModelOverrides.get(settings).scout).toEqual([peak, "manual/model"]);

  quota = "depleted";
  await command("peak", ctx);
  expect(settings.getModelRole("smol")).toBe(offpeak);
  expect(settings.getModelRole("task")).toBe(offpeak);
  expect(cfgTaskAgentModelOverrides.get(settings).scout).toEqual([offpeak, "manual/model"]);

  quota = "healthy";
  await command("peak", ctx);
  expect(settings.getModelRole("smol")).toBe(peak);
  expect(settings.getModelRole("task")).toBe(peak);
  await command("offpeak", ctx);
  await handlers.get("tool_call")!({ toolName: "task" }, ctx);
  expect(settings.getModelRole("smol")).toBe(offpeak);
  expect(cfgTaskAgentModelOverrides.get(settings).scout).toEqual([offpeak, "manual/model"]);
  expect(settings.getModelRole("default")).toBe("manual/model");
  expect(settings.getGlobalSettings()).toMatchObject({ modelRoles: roles, task: { agentModelOverrides: agents } });
 } finally {
  await handlers.get("session_shutdown")!({}, ctx);
  settings.cancelPendingSaves();
 }
});
