import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { z } from "zod";

/**
 * OMP Extension: alarm clock / timer for agent self-scheduling.
 *
 * Agents can set timers with an absolute ISO 8601 timestamp or a relative
 * duration. When the timer fires, the stored message is delivered as a
 * custom message, waking the agent if idle or queuing for the next turn.
 *
 * Tools:
 *   set_timer    — create a timer (at ISO or after_seconds + message)
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
 */
export default function(pi: ExtensionAPI) {
 pi.setLabel("AlarmClock");

 // ── State ──────────────────────────────────────────────

 /** IDs cancelled this session (so callbacks can short-circuit). */
 const cancelledThisSession = new Set<string>();
 let counter = 0;

 // ── Types ──────────────────────────────────────────────

 interface TimerEntry {
  id: string;
  label: string | null;
  message: string;
  at: string; // ISO 8601
 }

 // ── Type guards for session history entries ───────────

 function isTimerEntry(data: unknown): data is TimerEntry {
  if (!data || typeof data !== "object") return false;
  const d = data as Record<string, unknown>;
  return typeof d.id === "string" && typeof d.message === "string" && typeof d.at === "string";
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

 /** Deliver an alarm message to the agent. */
 function deliver(message: string, overdue: boolean) {
  const prefix = overdue ? "⏰ **Alarm** (overdue)" : "⏰ **Alarm**";
  pi.sendMessage(
   { customType: "alarm", content: `${prefix}: ${message}`, display: true, attribution: "user" },
   { deliverAs: "nextTurn", triggerTurn: true },
  );
 }

 /** Schedule a managed timeout. Callback checks cancelledThisSession before firing. */
 function schedule(
  id: string,
  atISO: string,
  message: string,
  delayMs: number,
  setTimeoutFn: (fn: () => void, ms: number) => unknown,
 ) {
  setTimeoutFn(() => {
   if (cancelledThisSession.has(id)) return;
   cancelledThisSession.delete(id);
   pi.appendEntry("timer-fired", { id, at: atISO, firedAt: new Date().toISOString() });
   deliver(message, false);
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
    deliver(t.message, true);
   } else {
    schedule(t.id, t.at, t.message, delayMs, (fn, ms) => ctx.setTimeout(fn, ms));
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
 });

 type SetTimerArgs = z.infer<typeof SetTimerParams>;

 pi.registerTool<z.ZodType<SetTimerArgs>>({
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
   pi.appendEntry("timer-set", entry);
   schedule(id, atISO, params.message, atMs - Date.now(), (fn, ms) => ctx.setTimeout(fn, ms));

   const labelStr = params.label ? ` ("${params.label}")` : "";
   const atLocal = new Date(atISO).toLocaleString();
   return {
    content: [{ type: "text", text: `Timer set${labelStr}. Fires at ${atLocal} (${atISO})\nID: ${id}` }],
    details: { id, at: atISO, label: params.label ?? null },
   };
  },
 });

 // ── Tool: list_timers ──────────────────────────────────

 const ListTimersParams = z.object({});
 type ListTimersArgs = z.infer<typeof ListTimersParams>;

 pi.registerTool<z.ZodType<ListTimersArgs>>({
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
    return `- \`${t.id}\`${labelStr}: "${t.message}" → ${t.at} (in ${remaining})`;
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
 type CancelTimerArgs = z.infer<typeof CancelTimerParams>;

 pi.registerTool<z.ZodType<CancelTimerArgs>>({
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
    ctx.ui.notify("No active timers", "info");
    return;
   }

   const lines = active.map(t => {
    const remainingMs = new Date(t.at).getTime() - nowMs;
    const remaining = remainingMs > 0 ? formatDuration(remainingMs) : "overdue";
    const labelStr = t.label ? ` [${t.label}]` : "";
    return `${t.id}${labelStr}: "${t.message}" (${remaining})`;
   });

   ctx.ui.notify(lines.join(" | "), "info");
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
