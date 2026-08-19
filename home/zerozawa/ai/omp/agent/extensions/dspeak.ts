import type { ExtensionAPI, ExtensionContext, Settings } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: dspeak — DeepSeek 高峰期自动避让（dsflash ↔ gpt-5.6-luna）。
 *
 * 背景：DeepSeek 官方峰谷定价（2026-08-17 生效），高峰时段为北京时间
 * 09:00–12:00、14:00–18:00，即 UTC 01:00–04:00、06:00–10:00（每日）。
 * 高峰期间 config.yml 里所有 `litellm/deepseek-v4-flash:*` 引用在运行时改指
 * `openai-codex/gpt-5.6-luna`（保留 `:thinking` 后缀）。
 *
 * 机制（纯扩展 API，不改 config.yml、不 patch 任何东西）：
 * - 通过 `pi.pi.settings.override(path, value)` 写 Settings 的「运行时覆盖层」
 *   （官方机制：优先级最高、永不持久化，进程退出即消失）。
 * - 覆盖两个键：`modelRoles`（tiny/smol/vision/commit/task 中的 flash 项）与
 *   `task.agentModelOverrides`（scout/librarian/… 中的 flash 项）。每次写入都
 *   是全量托管键集合，只含被改写为 luna 的键；目标为 flash 时整层清除，
 *   让 config.yml 原值直接透传。
 *
 * 钉住（pin）语义：
 * - 主会话：session_start 时判定一次并写 `dspeak.pin` marker 进 session 文件。
 *   resume / branch / tree / switch 时从分支历史重建 marker → 历史对话永不
 *   因高峰状态变化而自动切换；运行中的对话也不会在高峰边界切换。
 * - 主会话自身消费的角色（tiny/smol/vision/commit）= 钉住值，整个对话不变。
 * - 新 subagent：模型在 spawn preflight 一次性解析。本扩展在 `tool_call`
 *   （pre-exec，先于 preflight 读 settings）与主会话 `turn_start`、60s 心跳上刷新
 *   `modelRoles.task` + `task.agentModelOverrides` 为「当前时刻」判定值 →
 *   高峰中 spawn 的 subagent 用 luna，高峰过后新 spawn 的用 flash。
 * - subagent 会话也会加载本扩展：用 globalThis（Symbol.for）注册表协调，
 *   进程内首个会话为 owner，独占 pinned 键的写入权；非 owner 实例写入的
 *   全量映射与 owner 按时间确定性收敛，互不踩踏。
 *
 * 命令：
 *   /dspeak            — 查看状态
 *   /dspeak flash      — 手动锚定 flash（立即 re-pin 当前会话 + 写 marker）
 *   /dspeak luna       — 手动锚定 luna（同上）
 *   /dspeak auto       — 清除锚定，恢复按 UTC 高峰窗自动判定
 *   锚定是进程内存态，OMP 重启后消失；但当前会话的 re-pin 已写入 marker，
 *   该会话日后 resume 仍保持锚定时的选择。
 *
 * 注意：
 * - luna 不可用（未认证）时自动回退 flash 并提示一次。
 * - luna 额度（Codex 5h/周窗口）判定零模型调用：读 OMP 的 usage 报告
 *   （authStorage.getModelUsageHealth，数据来自 Codex usage 端点 + 响应头解析，
 *   5min 缓存；本扩展再加 60s 本地缓存）。额度 depleted → 视同 luna 不可用，
 *   钉住与浮动判定都回 flash；额度恢复后自动切回。
 * - 双保险：任一目标为 luna 时，运行时安装 `retry.fallbackChains`
 *   {openai-codex/gpt-5.6-luna: [litellm/deepseek-v4-flash:max]} 并开启
 *   `retry.usageAwareFallback`（默认关）。 OMP 原生 per-turn 预检在 luna
 *   耗尽时自动路由 flash（冷却结束自动恢复）；硬错误（429/quota）也走
 *   handleRetryableError → 同链回落。全部目标回 flash 时移除链与开关。
 *   用户自建的 luna 链键会被识别并让出，永不覆盖。
 * - 运行中用户通过 /models 手动改过的托管键会被检测到并让出（尊重手动选择）。
 * - clearOverride 会清掉整条路径的运行时覆盖层（含 --smol 等 CLI flag 的
 *   modelRoles 覆盖）；本机未使用此类 flag，可接受。
 */

// ── Constants ───────────────────────────────────────────────

const FLASH_SPEC = "litellm/deepseek-v4-flash";
const LUNA_SPEC = "openai-codex/gpt-5.6-luna";

/** DeepSeek 高峰窗，UTC 分钟数区间 [start, end)：北京 09:00-12:00 / 14:00-18:00。 */
const PEAK_WINDOWS_UTC: ReadonlyArray<readonly [number, number]> = [
 [1 * 60, 4 * 60], // 01:00–04:00 UTC
 [6 * 60, 10 * 60], // 06:00–10:00 UTC
];

const MARKER_TYPE = "dspeak.pin";

/** luna 额度健康本地缓存时长（上游 usage 报告本身还有 ~5min 缓存）。 */
const QUOTA_CACHE_MS = 60_000;

/** OMP 原生回落链：luna 耗尽/硬错误时 per-turn 自动路由到 flash。 */
const LUNA_CHAIN_KEY = LUNA_SPEC;
const LUNA_CHAIN_VALUE: string[] = [`${FLASH_SPEC}:max`];

// ── Types & shared process state ────────────────────────────

type Target = "flash" | "luna";

/** luna 额度三态：depleted → exhausted；查询失败 → unknown（判定时按可用放行）。 */
type LunaQuota = "ok" | "exhausted" | "unknown";

interface PinMarker {
 target: Target;
 at: string;
 reason: string;
}

interface ManagedEntry {
 /** 首次发现时 config.yml 里的原始值（string 或 string[]，含逗号列表与 :suffix），改写以其为准。 */
 original: string | string[];
 /** 本扩展上一次写入 override 的值；用于区分「还是我们的覆盖」vs「用户手动改了」。 */
 lastWritten: string | string[] | null;
}

interface DspeakShared {
 /** 手动锚定（进程内存态，重启消失）。 */
 anchor: Target | null;
 /** 进程内是否已有 owner 会话（首个 session_start 认领）。 */
 ownerClaimed: boolean;
 /** owner 会话的钉住选择（作用于 tiny/smol/vision/commit）。 */
 pinnedTarget: Target;
 roleManaged: Map<string, ManagedEntry>;
 agentManaged: Map<string, ManagedEntry>;
 wroteRoles: boolean;
 wroteAgents: boolean;
 warnedUnavailable: boolean;
 /** luna 额度健康（不调用模型；usage 端点/响应头数据）。 */
 lunaQuota: LunaQuota;
 lunaQuotaAt: number;
 /** retry.fallbackChains 运行时层是否由我们写入。 */
 chainManaged: boolean;
 /** 用户自有 luna 链（或改/删过我们写的键）→ 永不接管。 */
 chainUserOwned: boolean;
 /** 上次「额度耗尽」提示时刻；0 = 当前未处于已告知的耗尽期。 */
 quotaWarnedAt: number;
 /** 上次转发 OMP retry_fallback_applied 的提示时刻（限频）。 */
 fallbackNotifiedAt: number;
}

const GLOBAL_KEY = Symbol.for("omp.dspeak.v1");

function sharedState(): DspeakShared {
 const g = globalThis as unknown as Record<symbol, DspeakShared | undefined>;
 let s = g[GLOBAL_KEY];
 if (!s) {
  s = {
   anchor: null,
   ownerClaimed: false,
   pinnedTarget: "flash",
   roleManaged: new Map(),
   agentManaged: new Map(),
   wroteRoles: false,
   wroteAgents: false,
   warnedUnavailable: false,
   lunaQuota: "unknown",
   lunaQuotaAt: 0,
   chainManaged: false,
   chainUserOwned: false,
   quotaWarnedAt: 0,
   fallbackNotifiedAt: 0,
  };
  g[GLOBAL_KEY] = s;
 }
 return s;
}

// ── Time & target helpers ───────────────────────────────────

function isPeakUtc(nowMs: number): boolean {
 const d = new Date(nowMs);
 const mins = d.getUTCHours() * 60 + d.getUTCMinutes();
 return PEAK_WINDOWS_UTC.some(([start, end]) => mins >= start && mins < end);
}

/** 当前应选目标：锚定优先，否则按 UTC 高峰窗。 */
function pick(shared: DspeakShared): Target {
 if (shared.anchor) return shared.anchor;
 return isPeakUtc(Date.now()) ? "luna" : "flash";
}

/** luna 未认证时降级 flash（每进程只提示一次）。 */
function gateTarget(target: Target, lunaOk: boolean, shared: DspeakShared, ctx: ExtensionContext): Target {
 if (target === "luna" && !lunaOk) {
  if (!shared.warnedUnavailable) {
   shared.warnedUnavailable = true;
   ctx.ui.notify("dspeak: openai-codex/gpt-5.6-luna 不可用（未认证？），保持 deepseek-v4-flash", "warning");
  }
  return "flash";
 }
 return target;
}

/**
 * 刷新 luna 额度健康（零模型调用：Codex usage 端点 + 响应头解析的缓存报告）。
 * 60s 本地缓存；force 跳过缓存。返回状态是否发生变化。
 * 耗尽↔恢复的状态迁移会各提示一次（subagent 实例 ctx.hasUI=false,notify 为空操作）。
 */
async function refreshLunaQuota(
 pi: ExtensionAPI,
 ctx: ExtensionContext,
 shared: DspeakShared,
 force = false,
): Promise<boolean> {
 if (!force && Date.now() - shared.lunaQuotaAt < QUOTA_CACHE_MS) return false;
 shared.lunaQuotaAt = Date.now();
 let next: LunaQuota;
 try {
  const health = await ctx.modelRegistry.authStorage.getModelUsageHealth("openai-codex", {
   modelId: "gpt-5.6-luna",
   sessionId: ctx.sessionManager.getSessionId(),
   baseUrl: ctx.modelRegistry.getProviderBaseUrl("openai-codex"),
   reserveFraction: pi.pi.settings.get("retry.usageReservePct") / 100,
  });
  // reserve（最后 10%）不算耗尽：OMP per-turn 预检会按策略处理余量带。
  next = health.state === "depleted" ? "exhausted" : "ok";
 } catch {
  next = "unknown"; // 查询失败放行，由 OMP 回落链兜底
 }
 const changed = next !== shared.lunaQuota;
 shared.lunaQuota = next;
 if (next === "exhausted" && (changed || shared.quotaWarnedAt === 0)) {
  shared.quotaWarnedAt = Date.now();
  ctx.ui.notify("dspeak: gpt-5.6-luna 额度耗尽（周窗口），dsflash 角色暂回 flash；恢复后自动切回", "warning");
 } else if (next === "ok" && shared.quotaWarnedAt !== 0) {
  shared.quotaWarnedAt = 0;
  ctx.ui.notify("dspeak: gpt-5.6-luna 额度已恢复", "info");
 }
 return changed;
}

// ── Model spec rewriting ────────────────────────────────────

/** `provider/id:thinking` → ["provider/id", ":thinking"]；无后缀时 suffix = ""。 */
function splitThinkingSuffix(spec: string): [base: string, suffix: string] {
 const i = spec.lastIndexOf(":");
 if (i <= 0) return [spec, ""];
 return [spec.slice(0, i), spec.slice(i)];
}

/**
 * 改写一个设置值（string 或 string[]；string 内可能是逗号分隔的 pattern 列表）：
 * 把其中的 flash 项替换为 targetSpec 并保留各自的 :suffix，保持原有形状。
 * 值里没有 flash 时返回 null。targetSpec 为 null 表示改写回 flash 原样
 * （调用方用于探测；真正写回 flash 时直接省略该键透传 config）。
 */
function rewriteEntry(value: string | string[], targetSpec: string | null): string | string[] | null {
 const rewriteOne = (item: string): { text: string; found: boolean } => {
  const parts = item
   .split(",")
   .map(p => p.trim())
   .filter(Boolean);
  let found = false;
  const out = parts.map(p => {
   const [base, suffix] = splitThinkingSuffix(p);
   if (base === FLASH_SPEC) {
    found = true;
    return (targetSpec ?? FLASH_SPEC) + suffix;
   }
   return p;
  });
  return { text: out.join(", "), found };
 };

 if (Array.isArray(value)) {
  let found = false;
  const out = value.map(item => {
   const r = rewriteOne(item);
   found = found || r.found;
   return r.text;
  });
  return found ? out : null;
 }
 const r = rewriteOne(value);
 return r.found ? r.text : null;
}

// ── Settings override application ───────────────────────────

/**
 * 同步托管键集合：从 merged 视图发现新的 flash 键；识别用户手动改动并让出；
 * 清理 config 中已删除的键。
 */
function syncManaged(merged: Record<string, string | string[]> | undefined, managed: Map<string, ManagedEntry>): void {
 if (!merged) return;
 for (const [key, value] of Object.entries(merged)) {
  if (typeof value !== "string" && !Array.isArray(value)) continue;
  const entry = managed.get(key);
  if (!entry) {
   if (rewriteEntry(value, null) !== null) managed.set(key, { original: value, lastWritten: null });
   continue;
  }
  if (entry.lastWritten !== null && sameValue(value, entry.lastWritten)) continue; // 仍是我们的覆盖
  if (rewriteEntry(value, null) !== null) {
   // 裸 flash 值（我们的覆盖被清/未写）：刷新 original
   entry.original = value;
   entry.lastWritten = null;
  } else {
   // 用户运行时改成了别的模型 —— 尊重，让出托管
   managed.delete(key);
  }
 }
 for (const key of [...managed.keys()]) {
  if (!Object.hasOwn(merged, key)) managed.delete(key);
 }
}

function writeOverride(
 settings: Settings,
 path: "modelRoles" | "task.agentModelOverrides",
 out: Record<string, string | string[]>,
 shared: DspeakShared,
 flag: "wroteRoles" | "wroteAgents",
): void {
 if (Object.keys(out).length > 0) {
  settings.override(path, out);
  shared[flag] = true;
 } else if (shared[flag]) {
  settings.clearOverride(path);
  shared[flag] = false;
 }
}

/**
 * 应用全量托管映射。pinned 键（task 以外的 flash 角色）用 pinnedTarget，
 * 浮动键（modelRoles.task + task.agentModelOverrides）用当前时刻判定。
 * 目标为 flash 的键不写入（透传 config 原值）；整层为空时清除覆盖。
 */
function applyOverrides(pi: ExtensionAPI, ctx: ExtensionContext, shared: DspeakShared): void {
 const settings = pi.pi.settings;
 syncManaged(settings.get("modelRoles"), shared.roleManaged);
 syncManaged(settings.get("task.agentModelOverrides"), shared.agentManaged);

 const lunaOk = ctx.models.resolve(LUNA_SPEC) !== undefined && shared.lunaQuota !== "exhausted";
 const floatTarget = gateTarget(pick(shared), lunaOk, shared, ctx);
 const pinnedTarget = gateTarget(shared.pinnedTarget, lunaOk, shared, ctx);

 const roleOut: Record<string, string | string[]> = {};
 for (const [key, entry] of shared.roleManaged) {
  const target = key === "task" ? floatTarget : pinnedTarget;
  const written = target === "luna" ? rewriteEntry(entry.original, LUNA_SPEC) : null;
  if (written) {
   roleOut[key] = written;
   entry.lastWritten = written;
  } else {
   entry.lastWritten = null;
  }
 }
 writeOverride(settings, "modelRoles", roleOut, shared, "wroteRoles");

 const agentOut: Record<string, string | string[]> = {};
 for (const [key, entry] of shared.agentManaged) {
  const written = floatTarget === "luna" ? rewriteEntry(entry.original, LUNA_SPEC) : null;
  if (written) {
   agentOut[key] = written;
   entry.lastWritten = written;
  } else {
   entry.lastWritten = null;
  }
 }
 writeOverride(settings, "task.agentModelOverrides", agentOut, shared, "wroteAgents");

 syncFallbackChain(settings, shared, floatTarget === "luna" || pinnedTarget === "luna");
}

/**
 * 任一目标为 luna 时安装 OMP 原生回落链（luna → flash:max）并开启
 * usageAwareFallback（默认关）;全部回 flash 时移除,恢复 OMP 默认行为。
 * 链键被用户自建/改删时让出,永不覆盖用户配置。
 */
function syncFallbackChain(settings: Settings, shared: DspeakShared, lunaActive: boolean): void {
 const merged = settings.get("retry.fallbackChains") ?? {};
 const current = merged[LUNA_CHAIN_KEY];
 if (current !== undefined && !shared.chainManaged) shared.chainUserOwned = true;
 if (shared.chainManaged && !Array.isArray(current)) {
  // 用户删掉了我们写的键 → 让出
  shared.chainManaged = false;
  shared.chainUserOwned = true;
 }
 if (shared.chainManaged && Array.isArray(current) && !sameValue(current, LUNA_CHAIN_VALUE)) {
  // 用户改动了我们写的键 → 让出
  shared.chainManaged = false;
  shared.chainUserOwned = true;
 }
 if (shared.chainUserOwned) return;
 if (lunaActive && !shared.chainManaged) {
  settings.override("retry.fallbackChains", { ...merged, [LUNA_CHAIN_KEY]: [...LUNA_CHAIN_VALUE] });
  settings.override("retry.usageAwareFallback", true);
  shared.chainManaged = true;
 } else if (!lunaActive && shared.chainManaged) {
  settings.clearOverride("retry.fallbackChains");
  settings.clearOverride("retry.usageAwareFallback");
  shared.chainManaged = false;
 }
}

// ── Pin marker persistence ──────────────────────────────────

function isPinMarker(data: unknown): data is PinMarker {
 if (!data || typeof data !== "object") return false;
 const d = data as Record<string, unknown>;
 return (d.target === "flash" || d.target === "luna") && typeof d.at === "string";
}

/** 设置值相等（string 或 string[] 逐项）。 */
function sameValue(a: string | string[], b: string | string[]): boolean {
 if (Array.isArray(a) !== Array.isArray(b)) return false;
 if (!Array.isArray(a) && !Array.isArray(b)) return a === b;
 const aa = a as string[];
 const bb = b as string[];
 return aa.length === bb.length && aa.every((v, i) => v === bb[i]);
}

/**
 * owner 会话重建钉住值：分支历史里已有 marker → 恢复（resume/branch 不重新判定）；
 * 没有 → 按当前时刻判定并写 marker。
 */
function rebuildPin(pi: ExtensionAPI, ctx: ExtensionContext, shared: DspeakShared): void {
 let marker: PinMarker | undefined;
 for (const entry of ctx.sessionManager.getBranch()) {
  if (entry.type === "custom" && entry.customType === MARKER_TYPE && isPinMarker(entry.data)) {
   marker = entry.data;
  }
 }
 if (marker) {
  shared.pinnedTarget = marker.target;
  return;
 }
 const target = pick(shared);
 shared.pinnedTarget = target;
 pi.appendEntry(MARKER_TYPE, { target, at: new Date().toISOString(), reason: "session-start" } satisfies PinMarker);
}

// ── Extension ───────────────────────────────────────────────

export default function(pi: ExtensionAPI) {
 pi.setLabel("DsPeak");

 const shared = sharedState();
 /** 进程内首个会话认领 owner（主会话的 session_start 必然先于任何 subagent）。 */
 const isOwner = !shared.ownerClaimed && (shared.ownerClaimed = true);

 function notifySwitchIfLuna(ctx: ExtensionContext): void {
  // 钉住 luna 但额度耗尽/未认证时,实际生效 flash — 提示由 refreshLunaQuota/gateTarget 负责,此处不重复。
  const effective =
   shared.pinnedTarget === "luna" && shared.lunaQuota !== "exhausted" && ctx.models.resolve(LUNA_SPEC) !== undefined;
  if (!effective) return;
  ctx.ui.notify(
   `dspeak: DeepSeek 高峰时段（UTC 01:00-04:00 / 06:00-10:00），本会话 flash 角色已锚定为 gpt-5.6-luna`,
   "info",
  );
 }

 // ── Session lifecycle ───────────────────────────────────

 pi.on("session_start", async (_event, ctx) => {
  if (isOwner) {
   // 钉住判定前强制刷新额度:高峰 + luna 耗尽 → 本会话直接锚定 flash。
   await refreshLunaQuota(pi, ctx, shared, true);
   rebuildPin(pi, ctx, shared);
   applyOverrides(pi, ctx, shared);
   notifySwitchIfLuna(ctx);
   // 心跳:保证空闲跨过高峰边界/额度迁移后,下一个新 subagent 拿到当下判定。
   ctx.setInterval(() => {
    void refreshLunaQuota(pi, ctx, shared).then(() => applyOverrides(pi, ctx, shared));
   }, 60_000);
  } else {
   // subagent 实例:只收敛浮动键(pinnedTarget 已由 owner 写入注册表)。
   applyOverrides(pi, ctx, shared);
   void refreshLunaQuota(pi, ctx, shared);
  }
 });

 // 会话内切换/分支/历史导航：branch 继承 marker；switch 换分支后按新分支重建。
 const rebind = async (_event: unknown, ctx: ExtensionContext) => {
  if (!isOwner) return;
  await refreshLunaQuota(pi, ctx, shared);
  rebuildPin(pi, ctx, shared);
  applyOverrides(pi, ctx, shared);
 };
 pi.on("session_switch", rebind);
 pi.on("session_branch", rebind);
 pi.on("session_tree", rebind);

 // 新 subagent spawn 前（pre-exec，先于 preflight 读 settings）刷新浮动键。
 // 额度缓存过期时后台刷新（不阻塞 tool 执行），状态翻转后补一次 apply。
 pi.on("tool_call", (event, ctx) => {
  if (event.toolName !== "task") return;
  if (Date.now() - shared.lunaQuotaAt >= QUOTA_CACHE_MS) {
   void refreshLunaQuota(pi, ctx, shared).then(changed => {
    if (changed) applyOverrides(pi, ctx, shared);
   });
  }
  applyOverrides(pi, ctx, shared);
 });

 // 主会话每个 turn 开始刷新一次浮动键与额度（覆盖 vibe/runtime 等其他 spawn 路径）。
 pi.on("turn_start", async (_event, ctx) => {
  if (!isOwner) return;
  await refreshLunaQuota(pi, ctx, shared);
  applyOverrides(pi, ctx, shared);
 });

 // OMP 原生回落链生效时转发一次提示（10min 限频；subagent ctx notify 为空操作）。
 pi.on("retry_fallback_applied", (event, ctx) => {
  if (!event.from.includes(LUNA_SPEC)) return;
  if (Date.now() - shared.fallbackNotifiedAt < 10 * 60_000) return;
  shared.fallbackNotifiedAt = Date.now();
  ctx.ui.notify(`dspeak: luna 请求失败,OMP 已自动回落 ${event.to}(冷却后自动恢复)`, "warning");
 });

 pi.on("session_shutdown", async () => {
  if (isOwner) shared.ownerClaimed = false;
 });

 // ── Command: /dspeak ────────────────────────────────────

 pi.registerCommand("dspeak", {
  description: "DeepSeek 高峰避让：/dspeak flash|luna|auto|status",
  handler: async (args, ctx) => {
   const sub = (args.trim().split(/\s+/)[0] ?? "").toLowerCase() || "status";
   await refreshLunaQuota(pi, ctx, shared, true);

   if (sub === "flash" || sub === "luna" || sub === "auto" || sub === "clear" || sub === "off") {
    shared.anchor = sub === "flash" || sub === "luna" ? sub : null;
    if (isOwner) {
     // 显式锚定：立即 re-pin 当前会话并写 marker（resume 后保持）。
     shared.pinnedTarget = pick(shared);
     pi.appendEntry(MARKER_TYPE, {
      target: shared.pinnedTarget,
      at: new Date().toISOString(),
      reason: `anchor:${sub}`,
     } satisfies PinMarker);
    }
    applyOverrides(pi, ctx, shared);
    const anchorText = shared.anchor ? `锚定 ${shared.anchor}` : "自动（按 UTC 高峰窗）";
    ctx.ui.notify(
     `dspeak: ${anchorText}；本会话角色 → ${shared.pinnedTarget}，新 subagent → ${pick(shared)}`,
     "info",
    );
    return;
   }

   if (sub !== "status") {
    ctx.ui.notify(`dspeak: 未知参数 "${sub}"。用法：/dspeak flash|luna|auto|status`, "error");
    return;
   }

   const now = new Date();
   const hhmm = `${String(now.getUTCHours()).padStart(2, "0")}:${String(now.getUTCMinutes()).padStart(2, "0")}`;
   const peak = isPeakUtc(Date.now());
   const quotaText =
    shared.lunaQuota === "exhausted" ? "耗尽(周窗口)" : shared.lunaQuota === "ok" ? "可用" : "未知(查询失败放行)";
   const chainText = shared.chainUserOwned ? "用户自管" : shared.chainManaged ? "已安装 luna→flash" : "未安装";
   const lines = [
    `UTC ${hhmm} — ${peak ? "高峰时段" : "非高峰时段"}（窗口 01:00-04:00 / 06:00-10:00 UTC）`,
    `锚定: ${shared.anchor ?? "无"} | 本会话角色: ${shared.pinnedTarget} | 新 subagent: ${pick(shared)}`,
    `luna 额度: ${quotaText} | OMP 回落链: ${chainText}`,
    `托管 modelRoles: [${[...shared.roleManaged.keys()].join(", ") || "无"}]`,
    `托管 agentModelOverrides: [${[...shared.agentManaged.keys()].join(", ") || "无"}]`,
   ];
   ctx.ui.notify(lines.join("\n"), "info");
  },
 });
}
