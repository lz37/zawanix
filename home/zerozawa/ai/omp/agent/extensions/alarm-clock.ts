import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: alarm clock / timer for agent self-scheduling.
 *
 * Agents can set timers with an absolute ISO 8601 timestamp or a relative
 * duration. When the timer fires, the stored message is delivered as a
 * custom message, waking the agent if idle or (optionally) cutting into a
 * running agent loop.
 *
 * 投递模式（deliverAs）— agent 长时间自主运行不中断时闹钟是否切入 loop：
 *   nextTurn — 默认。agent 忙时排队隐藏消息，当前 turn 完全结束才消费；
 *              空闲立即开 turn。长时间不中断的自主任务会迟迟收不到闹钟。
 *   aside    — agent 忙时在下一个 step 边界注入，不打断在飞的工具批次；
 *              空闲直接开 turn（plan 模式折入上下文；尊重 Esc 打断不自动恢复）。
 *   steer    — 立即 agent.steer 进运行中的 loop，最激进。
 * 全局默认：config.yml 的 `alarmClock.deliverAs`（扩展命名空间 raw 键，
 * 每次投递时重读，改配置即生效）。单个闹钟：set_timer 的 deliver_as 参数覆盖。
 *
 * Tools:
 *   set_timer    — create a timer (at ISO or after_seconds + message, optional deliver_as)
 *   list_timers  — list pending timers
 *   cancel_timer — cancel by id or label
 *
 * Command:
 *   /timer       — list active timers in a notification
 *
 * Timers persist across session restarts via
 * appendEntry("timer-set"/"timer-fired"/"timer-cancelled").
 * Overdue timers fire immediately on session_start.
 *
 * Installation:
 *   extensions: ["~/.omp/agent/extensions/alarm-clock.ts"]
 *
 * NOTE: schemas MUST use the injected omptype zod (`pi.zod.z`), never npm
 * `zod` — OMP's toolWireSchema only converts omptype/TypeBox/raw JSON
 * schemas, and a real-zod object leaks through unconverted, leaving models
 * with a parameters schema of just the injected `i` intent field.
 */
export default function(pi: ExtensionAPI) {
 pi.setLabel("AlarmClock");
 const { z } = pi.zod;

 // ── State ──────────────────────────────────────────────

 /** IDs cancelled this session (so callbacks can short-circuit). */
 const cancelledThisSession = new Set<string>();
 let counter = 0;

 /** 投递模式：nextTurn 等 turn 结束（不打断）/ aside step 边界切入 / steer 立即切入 loop。 */
 type DeliverMode = "nextTurn" | "aside" | "steer";

 function asDeliverMode(value: unknown): DeliverMode | null {
  return value === "nextTurn" || value === "aside" || value === "steer" ? value : null;
 }

 /** 全局默认投递模式：config.yml 的 `alarmClock.deliverAs`；缺省 nextTurn（保持旧行为）。每次投递时重读，改配置即生效。 */
 function readDefaultDeliverAs(): DeliverMode {
  const raw: unknown = pi.pi.settings.getGlobalSettings().alarmClock;
  if (raw && typeof raw === "object" && "deliverAs" in raw) {
   const mode = asDeliverMode(raw.deliverAs);
   if (mode) return mode;
  }
  return "nextTurn";
 }

 // ── Types ──────────────────────────────────────────────

 interface TimerEntry {
  id: string;
  label: string | null;
  message: string;
  at: string; // ISO 8601
  /** 投递模式覆盖；缺省用全局 alarmClock.deliverAs（再缺省 nextTurn）。 */
  deliverAs?: DeliverMode;
 }

 // ── Type guards for session history entries ───────────

 function isTimerEntry(data: unknown): data is TimerEntry {
  if (!data || typeof data !== "object") return false;
  const d = data as Record<string, unknown>;
  return (
   typeof d.id === "string" &&
   typeof d.message === "string" &&
   typeof d.at === "string" &&
   (d.deliverAs === undefined || asDeliverMode(d.deliverAs) !== null)
  );
 }

 function hasId(data: unknown): data is { id: string } {
  return typeof data === "object" && data !== null && typeof (data as Record<string, unknown>).id === "string";
 }

 // ── Helpers ────────────────────────────────────────────

 /** Collect pending timers from session history (unfired, uncancelled). */
 function collectPending(branch: Iterable<{ type: string; customType?: string; data?: unknown }>): TimerEntry[] {
  const fired = new Set<string>();
  const cancelled = new Set<string>();
  const pending: TimerEntry[] = [];

  for (const entry of branch) {
   if (entry.type !== "custom" || !entry.customType || !entry.data) continue;
   switch (entry.customType) {
    case "timer-set":
     if (isTimerEntry(entry.data)) pending.push(entry.data);
     break;
    case "timer-fired":
     if (hasId(entry.data)) fired.add(entry.data.id);
     break;
    case "timer-cancelled":
     if (hasId(entry.data)) cancelled.add(entry.data.id);
     break;
   }
  }

  return pending.filter(t => !fired.has(t.id) && !cancelled.has(t.id));
 }

 /** Deliver an alarm message to the agent. mode 缺省读全局配置（投递时求值）。 */
 function deliver(message: string, overdue: boolean, mode: DeliverMode | undefined) {
  const prefix = overdue ? "⏰ **Alarm** (overdue)" : "⏰ **Alarm**";
  pi.sendMessage(
   { customType: "alarm", content: `${prefix}: ${message}`, display: true, attribution: "user" },
   { deliverAs: mode ?? readDefaultDeliverAs(), triggerTurn: true },
  );
 }

 /** Schedule a managed timeout. Callback checks cancelledThisSession before firing. */
 function schedule(
  id: string,
  atISO: string,
  message: string,
  delayMs: number,
  mode: DeliverMode | undefined,
  setTimeoutFn: (fn: () => void, ms: number) => unknown,
 ) {
  setTimeoutFn(() => {
   if (cancelledThisSession.has(id)) return;
   cancelledThisSession.delete(id);
   pi.appendEntry("timer-fired", { id, at: atISO, firedAt: new Date().toISOString() });
   deliver(message, false, mode);
  }, delayMs);
 }

 // ── Session lifecycle ──────────────────────────────────

 pi.on("session_start", async (_event, ctx) => {
  cancelledThisSession.clear();
  const nowMs = Date.now();
  for (const t of collectPending(ctx.sessionManager.getBranch())) {
   const atMs = new Date(t.at).getTime();
   const delayMs = atMs - nowMs;

   if (delayMs <= 0) {
    pi.appendEntry("timer-fired", { id: t.id, at: t.at, firedAt: new Date().toISOString(), late: true });
    deliver(t.message, true, t.deliverAs);
   } else {
    schedule(t.id, t.at, t.message, delayMs, t.deliverAs, (fn, ms) => ctx.setTimeout(fn, ms));
   }
  }
 });

 // ── Tool: set_timer ────────────────────────────────────

 const SetTimerParams = z.object({
  message: z.string().describe("Message to deliver when the timer fires"),
  at: z.string().optional()
   .describe("ISO 8601 timestamp (e.g. '2026-07-21T18:30:00+08:00'). Mutually exclusive with after_seconds."),
  after_seconds: z.number().positive().optional()
   .describe("Seconds from now. Mutually exclusive with at."),
  label: z.string().optional()
   .describe("Optional label for listing / cancelling the timer"),
  deliver_as: z.enum(["nextTurn", "aside", "steer"]).optional()
   .describe("Delivery when the timer fires: nextTurn = queue until the current turn fully ends (default; never interrupts long autonomous runs); aside = inject at the next step boundary without interrupting the in-flight tool batch; steer = steer into the running loop immediately. Overrides config alarmClock.deliverAs."),
 });

 pi.registerTool<typeof SetTimerParams>({
  name: "set_timer",
  label: "Set Timer",
  description: [
   "Create a timer/alarm that delivers a message to the agent at a future time.",
   "Use either 'at' (ISO 8601 timestamp) or 'after_seconds' (relative).",
   "Returns the timer ID for use with cancel_timer.",
  ].join("\n"),
  parameters: SetTimerParams,

  async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
   if (!params.at && !params.after_seconds) {
    return {
     content: [{ type: "text", text: "Must provide either 'at' (ISO timestamp) or 'after_seconds'." }],
     details: { error: "missing_time_spec" },
    };
   }
   if (params.at && params.after_seconds) {
    return {
     content: [{ type: "text", text: "Provide 'at' or 'after_seconds', not both." }],
     details: { error: "ambiguous_time_spec" },
    };
   }

   let atISO: string;
   if (params.at) {
    const parsed = new Date(params.at);
    if (isNaN(parsed.getTime())) {
     return {
      content: [{ type: "text", text: `Invalid ISO timestamp: "${params.at}". Use format like "2026-07-21T18:30:00+08:00".` }],
      details: { error: "invalid_iso" },
     };
    }
    atISO = parsed.toISOString();
   } else {
    atISO = new Date(Date.now() + params.after_seconds! * 1000).toISOString();
   }

   const atMs = new Date(atISO).getTime();
   if (atMs <= Date.now()) {
    return {
     content: [{ type: "text", text: "The specified time is in the past. Provide a future time." }],
     details: { error: "past_time" },
    };
   }

   counter++;
   const id = `t${Date.now().toString(36)}_${counter}`;
   const entry: TimerEntry = {
    id,
    label: params.label ?? null,
    message: params.message,
    at: atISO,
   };
   if (params.deliver_as) entry.deliverAs = params.deliver_as;
   pi.appendEntry("timer-set", entry);
   schedule(id, atISO, params.message, atMs - Date.now(), entry.deliverAs, (fn, ms) => ctx.setTimeout(fn, ms));

   const labelStr = params.label ? ` ("${params.label}")` : "";
   const modeStr = entry.deliverAs ? ` 投递: ${entry.deliverAs}.` : "";
   const atLocal = new Date(atISO).toLocaleString();
   return {
    content: [{ type: "text", text: `Timer set${labelStr}. Fires at ${atLocal} (${atISO})${modeStr}\nID: ${id}` }],
    details: { id, at: atISO, label: params.label ?? null, deliverAs: entry.deliverAs ?? null },
   };
  },
 });

 // ── Tool: list_timers ──────────────────────────────────

 const ListTimersParams = z.object({});

 pi.registerTool<typeof ListTimersParams>({
  name: "list_timers",
  label: "List Timers",
  description: "List all active (pending) timers with labels, remaining time, and messages.",
  parameters: ListTimersParams,

  async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
   const active = collectPending(ctx.sessionManager.getBranch());
   const nowMs = Date.now();
   const nowISO = new Date().toISOString();

   if (active.length === 0) {
    return {
     content: [{ type: "text", text: "No active timers." }],
     details: { timers: [], now: nowISO },
    };
   }

   const lines = active.map(t => {
    const remainingMs = new Date(t.at).getTime() - nowMs;
    const remaining = remainingMs > 0
     ? formatDuration(remainingMs)
     : "overdue";
    const labelStr = t.label ? ` [${t.label}]` : "";
    const modeStr = t.deliverAs ? ` {${t.deliverAs}}` : "";
    return `- \`${t.id}\`${labelStr}${modeStr}: "${t.message}" → ${t.at} (in ${remaining})`;
   });

   return {
    content: [{ type: "text", text: `Active timers (${active.length}):\n${lines.join("\n")}` }],
    details: { timers: active.map(t => ({ ...t, remainingMs: new Date(t.at).getTime() - nowMs })), now: nowISO },
   };
  },
 });

 // ── Tool: cancel_timer ─────────────────────────────────

 const CancelTimerParams = z.object({
  id: z.string().optional()
   .describe("Timer ID to cancel (returned by set_timer)."),
  label: z.string().optional()
   .describe("Label to cancel (cancels all timers with this label)."),
 });

 pi.registerTool<typeof CancelTimerParams>({
  name: "cancel_timer",
  label: "Cancel Timer",
  description: "Cancel an active timer by its ID or label.",
  parameters: CancelTimerParams,

  async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
   if (!params.id && !params.label) {
    return {
     content: [{ type: "text", text: "Must provide either 'id' or 'label' to cancel." }],
     details: { error: "missing_target" },
    };
   }

   const active = collectPending(ctx.sessionManager.getBranch());
   const toCancel = params.id
    ? active.filter(t => t.id === params.id)
    : active.filter(t => t.label === params.label);

   if (toCancel.length === 0) {
    const target = params.id ? `ID "${params.id}"` : `label "${params.label}"`;
    return {
     content: [{ type: "text", text: `No active timer found with ${target}.` }],
     details: { cancelled: 0 },
    };
   }

   for (const t of toCancel) {
    cancelledThisSession.add(t.id);
    pi.appendEntry("timer-cancelled", { id: t.id, at: t.at, cancelledAt: new Date().toISOString() });
   }

   return {
    content: [{ type: "text", text: `Cancelled ${toCancel.length} timer(s).` }],
    details: { cancelled: toCancel.length, ids: toCancel.map(t => t.id) },
   };
  },
 });

 // ── Command: /timer ────────────────────────────────────

 pi.registerCommand("timer", {
  description: "List active timers",
  handler: async (_args, ctx) => {
   const active = collectPending(ctx.sessionManager.getBranch());
   const nowMs = Date.now();

   if (active.length === 0) {
    ctx.ui.notify(`No active timers（默认投递: ${readDefaultDeliverAs()}）`, "info");
    return;
   }

   const lines = active.map(t => {
    const remainingMs = new Date(t.at).getTime() - nowMs;
    const remaining = remainingMs > 0 ? formatDuration(remainingMs) : "overdue";
    const labelStr = t.label ? ` [${t.label}]` : "";
    return `${t.id}${labelStr}: "${t.message}" (${remaining})`;
   });

   ctx.ui.notify(`默认投递: ${readDefaultDeliverAs()} | ` + lines.join(" | "), "info");
  },
 });
}

// ── Formatting ──────────────────────────────────────────────

function formatDuration(ms: number): string {
 if (ms < 60_000) return `${Math.ceil(ms / 1000)}s`;
 if (ms < 3_600_000) return `${Math.floor(ms / 60_000)}m ${Math.ceil((ms % 60_000) / 1000)}s`;
 const h = Math.floor(ms / 3_600_000);
 const m = Math.floor((ms % 3_600_000) / 60_000);
 return `${h}h ${m}m`;
}
