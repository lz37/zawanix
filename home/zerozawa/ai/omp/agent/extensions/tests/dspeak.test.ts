import { expect, test } from "bun:test";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { cfgModelRoles } from "@oh-my-pi/pi-coding-agent/config/model-settings";
import { Settings } from "@oh-my-pi/pi-coding-agent/config/settings";
import { cfgTaskAgentModelOverrides } from "@oh-my-pi/pi-coding-agent/task/settings";
import dspeak, { isPeakUtc } from "../dspeak";

test("peak windows exclude weekends, make-up workdays, and Chinese public holidays", () => {
 const at = (y: number, mo: number, d: number, h: number, mi = 0) => Date.UTC(y, mo - 1, d, h, mi);
 // 普通工作日：UTC 01:00-04:00 / 06:00-10:00 为高峰，边界左闭右开。
 expect(isPeakUtc(at(2026, 10, 19, 1))).toBe(true);
 expect(isPeakUtc(at(2026, 10, 19, 3, 59))).toBe(true);
 expect(isPeakUtc(at(2026, 10, 19, 4))).toBe(false);
 expect(isPeakUtc(at(2026, 10, 19, 5, 30))).toBe(false); // 北京 13:30 午休
 expect(isPeakUtc(at(2026, 10, 19, 6))).toBe(true);
 expect(isPeakUtc(at(2026, 10, 19, 9, 59))).toBe(true);
 expect(isPeakUtc(at(2026, 10, 19, 10))).toBe(false);
 // 周末，含调休补班的周日/周六，仍全天低谷。
 expect(isPeakUtc(at(2026, 9, 20, 2))).toBe(false); // 周日补班
 expect(isPeakUtc(at(2026, 10, 10, 2))).toBe(false); // 周六补班
 // 工作日法定节假日：春节、中秋、国庆、元旦全天低谷。
 expect(isPeakUtc(at(2026, 2, 17, 2))).toBe(false);
 expect(isPeakUtc(at(2026, 9, 25, 2))).toBe(false);
 expect(isPeakUtc(at(2026, 10, 1, 2))).toBe(false);
 expect(isPeakUtc(at(2026, 10, 7, 2))).toBe(false);
 expect(isPeakUtc(at(2026, 1, 2, 2))).toBe(false);
 // 假期前后紧邻的工作日仍按高峰。
 expect(isPeakUtc(at(2026, 9, 24, 2))).toBe(true);
 expect(isPeakUtc(at(2026, 10, 8, 2))).toBe(true);
});

test("pin restores recorded mode, skips unresolvable selectors, and never persists resolved values", async () => {
 const peak = "litellm/MiniMax-M3.1-Flash:xhigh";
 const offpeak = "litellm/deepseek-v4.1-flash:max";
 const selector = `dspeak/peak=${peak}&default=${offpeak}`;
 const settings = Settings.isolated();
 const roles = { smol: selector, task: selector, default: "manual/model" };
 const agents = { scout: [selector, "manual/model"] };
 cfgModelRoles.set(settings, roles);
 cfgTaskAgentModelOverrides.set(settings, agents);
 const resolvable = new Set([peak, offpeak]);
 const handlers = new Map<string, (event: unknown, ctx: ExtensionContext) => unknown>();
 let command!: (args: string, ctx: ExtensionContext) => Promise<void>;
 const branch = [{ type: "custom", customType: "dspeak.pin", data: { mode: "peak" } }];
 const notices: string[] = [];
 const ctx = {
  hasUI: false,
  ui: { notify(message: string) { notices.push(message); } },
  models: { resolve: (spec: string) => resolvable.has(spec) ? { id: spec } : undefined },
  sessionManager: { getBranch: () => branch },
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

  resolvable.delete(peak);
  await command("peak", ctx);
  expect(settings.getModelRole("smol")).toBe(offpeak);
  expect(settings.getModelRole("task")).toBe(offpeak);
  expect(cfgTaskAgentModelOverrides.get(settings).scout).toEqual([offpeak, "manual/model"]);

  resolvable.add(peak);
  await command("peak", ctx);
  expect(settings.getModelRole("smol")).toBe(peak);
  expect(settings.getModelRole("task")).toBe(peak);
  await command("offpeak", ctx);
  await handlers.get("tool_call")!({ toolName: "task" }, ctx);
  expect(settings.getModelRole("smol")).toBe(offpeak);
  expect(cfgTaskAgentModelOverrides.get(settings).scout).toEqual([offpeak, "manual/model"]);
  expect(settings.getModelRole("default")).toBe("manual/model");
  expect(settings.getGlobalSettings()).toMatchObject({ modelRoles: roles, task: { agentModelOverrides: agents } });

  await command("status", ctx);
  expect(notices.at(-1)).toContain("节假日库: chinese-workday");
 } finally {
  await handlers.get("session_shutdown")!({}, ctx);
  settings.cancelPendingSaves();
 }
});
