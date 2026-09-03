import type { ExtensionAPI, ExtensionContext, Settings } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: dspeak — DeepSeek 高峰期自动避让（`dspeak/` 占位符条件选择器）。
 *
 * 背景：DeepSeek 官方峰谷定价（2026-08-17 生效），高峰时段为北京时间
 * 09:00–12:00、14:00–18:00，即 UTC 01:00–04:00、06:00–10:00（每日）。
 * 2026-08-23 起周六、周日（北京时间）全天统一按低谷价，周末永不高峰。
 *
 * 占位符语法（写在 config.yml 的 modelRoles / task.agentModelOverrides 值里）：
 *
 *   dspeak/<条件>=<原生spec>[&<条件>=<原生spec>...]
 *
 *   例：dspeak/peak=openai-codex/gpt-5.6-luna:max&default=litellm/deepseek-v4-flash:max
 *
 * - 条件：`peak`（DeepSeek 高峰窗）、`offpeak`（非高峰窗）、`default`（兜底）。
 * - 求值顺序：先按书写顺序试非 default 分支，再按书写顺序试 default 分支
 *   （default 写在哪都是最后兜底）。每个分支的 spec 是完整的原生
 *   `provider/model[:thinking]`，原样进入 OMP 解析。
 * - 分支闸门：条件命中后还要求 (a) spec 可被 modelRegistry 解析（未认证/未
 *   发现则跳过），(b) 若 provider 是 openai-codex 则其额度未耗尽（见下）。
 *   所有命中分支都被闸门拦下时，退化为「第一个 default 分支 ?? 第一个分支」
 *   的原样 spec（ungated —— 配置错误会经由 OMP 自身的 unresolved 警告暴露）。
 * - 占位符可出现在逗号优先级列表或数组值的任意一项里，改写保持原有形状。
 * - 非 `dspeak/` 前缀的值（即手动指定的真实模型名）一律不托管、不动。
 *
 * 机制（纯扩展 API，不改 config.yml、不 patch 任何东西）：
 * - 通过 `pi.pi.settings.override(path, value)` 写 Settings 的「运行时覆盖层」
 *   （官方机制：优先级最高、永不持久化，进程退出即消失）。覆盖两个键：
 *   `modelRoles` 与 `task.agentModelOverrides` 中含占位符的条目。
 * - 与旧版（按真实模型名发现）的关键差异：占位符本身不可被 OMP 解析，因此
 *   覆盖层对托管键【始终在场】（高峰→peak 分支 spec，非高峰→default 分支 spec），
 *   不存在「目标 flash 时整层清除透传」。config.yml 里的占位符永远不会到达
 *   OMP 的模型解析器——除非扩展未加载（此时角色解析落警告+降级，不硬报错）。
 * - 角色模型在调用点惰性解析（resolveModelRoleValue），override 写入即刻生效。
 *
 * 钉住（pin）语义：
 * - 主会话：session_start 时判定一次高峰/非高峰并写 `dspeak.pin` marker 进
 *   session 文件（存的是 mode：peak|offpeak，不是具体模型）。resume / branch /
 *   tree / switch 时从分支历史重建 → 历史对话永不因高峰状态变化而切换分支；
 *   运行中的对话也不会在高峰边界切换。旧版 marker（{target: flash|luna}）自动
 *   迁移：flash→offpeak，luna→peak。
 * - 主会话自身消费的角色（tiny/smol/vision/commit/advisor）= 钉住 mode，整个
 *   对话不变；每个键实际用什么模型由该键自己的占位符分支决定。
 * - 新 subagent：模型在 spawn preflight 一次性解析。本扩展在 `tool_call`
 *   （pre-exec，先于 preflight 读 settings）与主会话 `turn_start`、60s 心跳上刷新
 *   `modelRoles.task` + `task.agentModelOverrides` 为「当前时刻」判定 →
 *   高峰中 spawn 的 subagent 走 peak 分支，高峰过后新 spawn 的走 default 分支。
 * - subagent 会话也会加载本扩展：用 globalThis（Symbol.for）注册表协调，
 *   进程内首个会话为 owner，独占 pinned 键的写入权；非 owner 实例写入的
 *   全量映射与 owner 按时间确定性收敛，互不踩踏。
 *
 * openai-codex 额度门（零模型调用）：
 * - 对所有出现在占位符分支里的 openai-codex 模型，读 OMP 的 usage 报告
 *   （authStorage.getModelUsageHealth，数据来自 Codex usage 端点 + 响应头解析，
 *   5min 缓存；本扩展再加 60s 本地缓存）。额度 depleted → 该分支视同不可用被
 *   跳过（钉住与浮动判定都一样）；额度恢复后自动切回。查询失败按可用放行。
 * - 不安装 OMP 回落链、不开 `retry.usageAwareFallback`：分支模型的瞬时错误
 *   （429/超时/网络抖动）只走 OMP 原生同模型重试，不自动改道——避免峰时回落
 *   到峰时计费的 flash，也避免 OMP 把 luna 压入 5–30min 冷却。
 *
 * 命令：
 *   /dspeak            — 查看状态（含每个托管键当前解析到的真实 spec）
 *   /dspeak peak       — 手动锚定高峰分支（别名 luna；立即 re-pin + 写 marker）
 *   /dspeak offpeak    — 手动锚定非高峰分支（别名 flash；同上）
 *   /dspeak auto       — 清除锚定，恢复按 UTC 高峰窗自动判定（别名 clear/off）
 *   锚定是进程内存态，OMP 重启后消失；但当前会话的 re-pin 已写入 marker，
 *   该会话日后 resume 仍保持锚定时的分支选择。
 *
 * 注意：
 * - 运行中用户通过 /models 手动改过的托管键会被检测到并让出（尊重手动选择）。
 * - override(path, …) / clearOverride(path) 作用在整条 modelRoles 覆盖层上，
 *   会顶掉 --smol 等 CLI flag 写入同层的覆盖；本机未使用此类 flag，可接受。
 * - 扩展未加载时占位符不可解析：OMP 对各角色打 "No models match pattern"
 *   警告并按各自回退链降级（不硬错误）。恢复扩展即恢复正常。
 */

// ── Constants ───────────────────────────────────────────────

/** 占位符前缀：设置值中以此开头的条目由本扩展托管解析。 */
const DSPEAK_PREFIX = "dspeak/";

/** DeepSeek 高峰窗，UTC 分钟数区间 [start, end)：北京 09:00-12:00 / 14:00-18:00，仅周一至周五（北京时间周末全天低谷）。 */
const PEAK_WINDOWS_UTC: ReadonlyArray<readonly [number, number]> = [
 [1 * 60, 4 * 60], // 01:00–04:00 UTC
 [6 * 60, 10 * 60], // 06:00–10:00 UTC
];

const MARKER_TYPE = "dspeak.pin";

/** 额度健康本地缓存时长（上游 usage 报告本身还有 ~5min 缓存）。 */
const QUOTA_CACHE_MS = 60_000;

/** 额度门只对该 provider 生效（authStorage.getModelUsageHealth 的数据源）。 */
const QUOTA_PROVIDER = "openai-codex";

// ── Types & shared process state ────────────────────────────

/** 高峰判定模式：peak = 高峰窗，offpeak = 非高峰窗。 */
type Mode = "peak" | "offpeak";

/** 占位符分支条件。default 无条件命中，兜底。 */
type Cond = "peak" | "offpeak" | "default";

/** 额度三态：depleted → exhausted；查询失败 → unknown（判定时按可用放行）。 */
type QuotaState = "ok" | "exhausted" | "unknown";

interface Branch {
 cond: Cond;
 /** 完整原生模型 spec（`provider/model[:thinking]`）。 */
 spec: string;
}

type PlaceholderParse = { branches: Branch[] } | { error: string };

interface PinMarker {
 mode: Mode;
 at: string;
 reason: string;
}

interface ManagedEntry {
 /** 首次发现时 config.yml 里的原始值（string 或 string[]，含占位符项），改写以其为准。 */
 original: string | string[];
 /** 本扩展上一次写入 override 的值；用于区分「还是我们的覆盖」vs「用户手动改了」。 */
 lastWritten: string | string[] | null;
}

interface QuotaEntry {
 state: QuotaState;
 at: number;
 /** 上次「额度耗尽」提示时刻；0 = 当前未处于已告知的耗尽期。 */
 warnedAt: number;
}

interface Skip {
 spec: string;
 reason: "unresolvable" | "quota";
}

interface DspeakShared {
 /** 手动锚定（进程内存态，重启消失）。 */
 anchor: Mode | null;
 /** 进程内是否已有 owner 会话（首个 session_start 认领）。 */
 ownerClaimed: boolean;
 /** owner 会话的钉住模式（作用于 task 以外的托管角色）。 */
 pinnedMode: Mode;
 roleManaged: Map<string, ManagedEntry>;
 agentManaged: Map<string, ManagedEntry>;
 wroteRoles: boolean;
 wroteAgents: boolean;
 /** openai-codex 模型额度健康，key = 无后缀的 provider/model。 */
 quota: Map<string, QuotaEntry>;
 /** 已提示过的畸形占位符键（path.key）。 */
 malformedWarned: Set<string>;
 /** 已提示过的不可解析分支 spec。 */
 unresolvableWarned: Set<string>;
}

const GLOBAL_KEY = Symbol.for("omp.dspeak.v2");

function sharedState(): DspeakShared {
 const g = globalThis as unknown as Record<symbol, DspeakShared | undefined>;
 let s = g[GLOBAL_KEY];
 if (!s) {
  s = {
   anchor: null,
   ownerClaimed: false,
   pinnedMode: "offpeak",
   roleManaged: new Map(),
   agentManaged: new Map(),
   wroteRoles: false,
   wroteAgents: false,
   quota: new Map(),
   malformedWarned: new Set(),
   unresolvableWarned: new Set(),
  };
  g[GLOBAL_KEY] = s;
 }
 return s;
}

// ── Placeholder parsing ─────────────────────────────────────

/** `provider/id:thinking` → ["provider/id", ":thinking"]；无后缀时 suffix = ""。 */
function splitThinkingSuffix(spec: string): [base: string, suffix: string] {
 const i = spec.lastIndexOf(":");
 if (i <= 0) return [spec, ""];
 return [spec.slice(0, i), spec.slice(i)];
}

/** `provider/model` → { provider, modelId }（modelId 可含 `/`）。 */
function specProviderModel(base: string): { provider: string; modelId: string } | null {
 const i = base.indexOf("/");
 if (i <= 0 || i === base.length - 1) return null;
 return { provider: base.slice(0, i), modelId: base.slice(i + 1) };
}

/**
 * 解析一个占位符条目：`dspeak/<cond>=<spec>[&<cond>=<spec>...]`。
 * 非占位符返回 null；占位符但畸形返回 { error }（调用方透传并提示）。
 */
function parsePlaceholder(item: string): PlaceholderParse | null {
 if (!item.startsWith(DSPEAK_PREFIX)) return null;
 const body = item.slice(DSPEAK_PREFIX.length).trim();
 if (!body) return { error: "空占位符" };
 const branches: Branch[] = [];
 for (const part of body.split("&")) {
  const eq = part.indexOf("=");
  if (eq <= 0) return { error: `分支缺少 "条件=spec" 形式: "${part}"` };
  const cond = part.slice(0, eq).trim();
  const spec = part.slice(eq + 1).trim();
  if (cond !== "peak" && cond !== "offpeak" && cond !== "default") {
   return { error: `未知条件 "${cond}"（支持 peak / offpeak / default）` };
  }
  if (!spec) return { error: `分支 "${cond}" 缺少模型 spec` };
  if (spec.startsWith(DSPEAK_PREFIX)) return { error: "分支 spec 不能嵌套占位符" };
  if (spec.includes(",")) return { error: `分支 spec 不能含逗号: "${spec}"` };
  branches.push({ cond, spec });
 }
 return { branches };
}

/** 设置值（string / string[]，string 内可逗号分隔）展开成条目列表。 */
function flattenItems(value: string | string[]): string[] {
 const items = Array.isArray(value) ? value : [value];
 return items.flatMap(item =>
  item
   .split(",")
   .map(p => p.trim())
   .filter(Boolean),
 );
}

/** 值里是否含占位符条目（畸形也算，便于托管后提示）。 */
function hasPlaceholder(value: string | string[]): boolean {
 return flattenItems(value).some(item => item.startsWith(DSPEAK_PREFIX));
}

// ── Time & mode helpers ─────────────────────────────────────

function isPeakUtc(nowMs: number): boolean {
 // 北京时间周六/周日全天低谷（2026-08-23 起）；UTC+8 无夏令时。
 const bjDay = new Date(nowMs + 8 * 3_600_000).getUTCDay();
 if (bjDay === 0 || bjDay === 6) return false;
 const d = new Date(nowMs);
 const mins = d.getUTCHours() * 60 + d.getUTCMinutes();
 return PEAK_WINDOWS_UTC.some(([start, end]) => mins >= start && mins < end);
}

/** 当前应选模式：锚定优先，否则按 UTC 高峰窗。 */
function pick(shared: DspeakShared): Mode {
 if (shared.anchor) return shared.anchor;
 return isPeakUtc(Date.now()) ? "peak" : "offpeak";
}

// ── Quota gate (openai-codex usage, zero model calls) ───────

/** 收集所有占位符分支里出现的 openai-codex 模型（无后缀的 provider/model）。 */
function collectQuotaSpecs(settings: Settings, shared: DspeakShared): Set<string> {
 const out = new Set<string>();
 const scan = (value: unknown): void => {
  if (typeof value !== "string" && !Array.isArray(value)) return;
  for (const item of flattenItems(value as string | string[])) {
   const parsed = parsePlaceholder(item);
   if (!parsed || "error" in parsed) continue;
   for (const b of parsed.branches) {
    const pm = specProviderModel(splitThinkingSuffix(b.spec)[0]);
    if (pm?.provider === QUOTA_PROVIDER) out.add(splitThinkingSuffix(b.spec)[0]);
   }
  }
 };
 const roles = settings.get("modelRoles");
 const agents = settings.get("task.agentModelOverrides");
 for (const v of Object.values(roles ?? {})) scan(v);
 for (const v of Object.values(agents ?? {})) scan(v);
 // 覆盖层在场时 merged 视图里是我们解析后的真实 spec，占位符只在 original 里。
 for (const e of shared.roleManaged.values()) scan(e.original);
 for (const e of shared.agentManaged.values()) scan(e.original);
 return out;
}

function quotaNeedsRefresh(settings: Settings, shared: DspeakShared): boolean {
 const now = Date.now();
 for (const base of collectQuotaSpecs(settings, shared)) {
  const e = shared.quota.get(base);
  if (!e || now - e.at >= QUOTA_CACHE_MS) return true;
 }
 return false;
}

/**
 * 刷新所有占位符分支里 openai-codex 模型的额度健康（零模型调用）。
 * 60s 本地缓存；force 跳过缓存。返回是否有状态变化。
 * 耗尽↔恢复的迁移各提示一次（subagent 实例 ctx.hasUI=false，notify 为空操作）。
 */
async function refreshQuotas(
 pi: ExtensionAPI,
 ctx: ExtensionContext,
 shared: DspeakShared,
 force = false,
): Promise<boolean> {
 const now = Date.now();
 let changed = false;
 for (const base of collectQuotaSpecs(pi.pi.settings, shared)) {
  const existing = shared.quota.get(base);
  if (!force && existing && now - existing.at < QUOTA_CACHE_MS) continue;
  const pm = specProviderModel(base);
  if (!pm) continue;
  let next: QuotaState;
  try {
   const health = await ctx.modelRegistry.authStorage.getModelUsageHealth(pm.provider, {
    modelId: pm.modelId,
    sessionId: ctx.sessionManager.getSessionId(),
    baseUrl: ctx.modelRegistry.getProviderBaseUrl(pm.provider),
    reserveFraction: pi.pi.settings.get("retry.usageReservePct") / 100,
   });
   // reserve（最后 10%）不算耗尽：余量带继续用（本扩展不开 usageAwareFallback，无预检改道）。
   next = health.state === "depleted" ? "exhausted" : "ok";
  } catch {
   next = "unknown"; // 查询失败放行：无回落链，真挂时走 OMP 同模型重试
  }
  if (existing && existing.state !== next) changed = true;
  const entry: QuotaEntry = { state: next, at: now, warnedAt: existing?.warnedAt ?? 0 };
  shared.quota.set(base, entry);
  if (next === "exhausted" && entry.warnedAt === 0) {
   entry.warnedAt = now;
   ctx.ui.notify(`dspeak: ${base} 额度耗尽（周窗口），其占位符分支暂被跳过；恢复后自动切回`, "warning");
  } else if (next !== "exhausted" && entry.warnedAt !== 0) {
   entry.warnedAt = 0;
   if (next === "ok") ctx.ui.notify(`dspeak: ${base} 额度已恢复`, "info");
  }
 }
 return changed;
}

// ── Placeholder resolution ──────────────────────────────────

interface ResolveEnv {
 peak: boolean;
 isResolvable: (spec: string) => boolean;
 quotaOk: (spec: string) => boolean;
}

interface Resolution {
 spec: string;
 cond: Cond;
 /** true = 所有命中分支都被闸门拦下，本次返回的是 ungated 兜底分支。 */
 gated: boolean;
 skips: Skip[];
}

/**
 * 求值占位符：先按书写顺序试非 default 分支，再按书写顺序试 default 分支。
 * 条件命中 + 可解析 + 额度未耗尽 → 采用。全部被拦 → 第一个 default 分支 ??
 * 第一个分支的 ungated 原样 spec（让配置错误暴露而非静默）。
 */
function resolvePlaceholder(branches: Branch[], env: ResolveEnv): Resolution {
 const ordered = [...branches.filter(b => b.cond !== "default"), ...branches.filter(b => b.cond === "default")];
 const skips: Skip[] = [];
 for (const b of ordered) {
  if (b.cond === "peak" && !env.peak) continue;
  if (b.cond === "offpeak" && env.peak) continue;
  if (!env.isResolvable(b.spec)) {
   skips.push({ spec: b.spec, reason: "unresolvable" });
   continue;
  }
  if (!env.quotaOk(b.spec)) {
   skips.push({ spec: b.spec, reason: "quota" });
   continue;
  }
  return { spec: b.spec, cond: b.cond, gated: false, skips };
 }
 const fallback = (ordered.find(b => b.cond === "default") ?? ordered[0])!;
 return { spec: fallback.spec, cond: fallback.cond, gated: true, skips };
}

interface RewriteResult {
 /** 有占位符被改写时为改写后的值（保持原形状），否则 null。 */
 value: string | string[] | null;
 skips: Skip[];
}

/**
 * 改写一个设置值：把其中的占位符条目解析为真实 spec，保持原有形状
 * （string / string[]、逗号列表）。畸形占位符条目原样保留（OMP 解析时会报警，
 * 上层按键一次性提示）。值里没有占位符时 value = null。
 */
function rewriteEntry(value: string | string[], env: ResolveEnv): RewriteResult {
 const skips: Skip[] = [];
 const rewriteOne = (item: string): { text: string; found: boolean } => {
  const parts = item
   .split(",")
   .map(p => p.trim())
   .filter(Boolean);
  let found = false;
  const out = parts.map(p => {
   const parsed = parsePlaceholder(p);
   if (!parsed || "error" in parsed) return p;
   found = true;
   const r = resolvePlaceholder(parsed.branches, env);
   skips.push(...r.skips);
   return r.spec;
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
  return { value: found ? out : null, skips };
 }
 const r = rewriteOne(value);
 return { value: r.found ? r.text : null, skips };
}

// ── Settings override application ───────────────────────────

/**
 * 同步托管键集合：从 merged 视图发现新的占位符键；识别用户手动改动并让出；
 * 清理 config 中已删除的键。
 */
function syncManaged(merged: Record<string, string | string[]> | undefined, managed: Map<string, ManagedEntry>): void {
 if (!merged) return;
 for (const [key, value] of Object.entries(merged)) {
  if (typeof value !== "string" && !Array.isArray(value)) continue;
  const entry = managed.get(key);
  if (!entry) {
   if (hasPlaceholder(value)) managed.set(key, { original: value, lastWritten: null });
   continue;
  }
  if (entry.lastWritten !== null && sameValue(value, entry.lastWritten)) continue; // 仍是我们的覆盖
  if (hasPlaceholder(value)) {
   // 裸占位符值（我们的覆盖被清/未写，或用户改了占位符本身）：刷新 original
   entry.original = value;
   entry.lastWritten = null;
  } else {
   // 用户运行时改成了真实模型名 —— 尊重，让出托管
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

/** 畸形占位符一次性报错（按 path.key）。 */
function warnMalformed(ctx: ExtensionContext, shared: DspeakShared, path: string, key: string, original: string | string[]): void {
 for (const item of flattenItems(original)) {
  const parsed = parsePlaceholder(item);
  if (!parsed || !("error" in parsed)) continue;
  const id = `${path}.${key}`;
  if (shared.malformedWarned.has(id)) continue;
  shared.malformedWarned.add(id);
  ctx.ui.notify(`dspeak: 占位符解析失败 ${id}: ${parsed.error}`, "error");
 }
}

/** 被闸门跳过的分支一次性提示（按 spec；quota 跳过的迁移提示由 refreshQuotas 负责）。 */
function warnSkips(ctx: ExtensionContext, shared: DspeakShared, skips: Skip[]): void {
 for (const skip of skips) {
  if (skip.reason !== "unresolvable" || shared.unresolvableWarned.has(skip.spec)) continue;
  shared.unresolvableWarned.add(skip.spec);
  ctx.ui.notify(`dspeak: ${skip.spec} 不可解析（未认证？），该分支被跳过`, "warning");
 }
}

/**
 * 应用全量托管映射。钉住键（task 以外的托管角色）用 pinnedMode，浮动键
 * （modelRoles.task + task.agentModelOverrides）用当前时刻判定。
 * 占位符不可被 OMP 解析，覆盖层对托管键始终在场（无「透传 config」状态）。
 */
function applyOverrides(pi: ExtensionAPI, ctx: ExtensionContext, shared: DspeakShared): void {
 const settings = pi.pi.settings;
 syncManaged(settings.get("modelRoles"), shared.roleManaged);
 syncManaged(settings.get("task.agentModelOverrides"), shared.agentManaged);

 const env: ResolveEnv = {
  peak: false, // 每个键写入前设置
  isResolvable: spec => ctx.models.resolve(spec) !== undefined,
  quotaOk: spec => shared.quota.get(splitThinkingSuffix(spec)[0])?.state !== "exhausted",
 };
 const floatPeak = pick(shared) === "peak";
 const pinnedPeak = shared.pinnedMode === "peak";

 const roleOut: Record<string, string | string[]> = {};
 for (const [key, entry] of shared.roleManaged) {
  warnMalformed(ctx, shared, "modelRoles", key, entry.original);
  env.peak = key === "task" ? floatPeak : pinnedPeak;
  const { value, skips } = rewriteEntry(entry.original, env);
  warnSkips(ctx, shared, skips);
  if (value !== null) {
   roleOut[key] = value;
   entry.lastWritten = value;
  } else {
   entry.lastWritten = null;
  }
 }
 writeOverride(settings, "modelRoles", roleOut, shared, "wroteRoles");

 const agentOut: Record<string, string | string[]> = {};
 for (const [key, entry] of shared.agentManaged) {
  warnMalformed(ctx, shared, "task.agentModelOverrides", key, entry.original);
  env.peak = floatPeak;
  const { value, skips } = rewriteEntry(entry.original, env);
  warnSkips(ctx, shared, skips);
  if (value !== null) {
   agentOut[key] = value;
   entry.lastWritten = value;
  } else {
   entry.lastWritten = null;
  }
 }
 writeOverride(settings, "task.agentModelOverrides", agentOut, shared, "wroteAgents");
}

// ── Pin marker persistence ──────────────────────────────────

/** 读取 marker 的 mode；兼容旧版 {target: flash|luna}（flash→offpeak，luna→peak）。 */
function markerMode(data: unknown): Mode | null {
 if (!data || typeof data !== "object") return null;
 const d = data as Record<string, unknown>;
 if (d.mode === "peak" || d.mode === "offpeak") return d.mode;
 if (d.target === "luna") return "peak";
 if (d.target === "flash") return "offpeak";
 return null;
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
 * owner 会话重建钉住模式：分支历史里已有 marker → 恢复（resume/branch 不重新
 * 判定）；没有 → 按当前时刻判定并写 marker。
 */
function rebuildPin(pi: ExtensionAPI, ctx: ExtensionContext, shared: DspeakShared): void {
 let mode: Mode | undefined;
 for (const entry of ctx.sessionManager.getBranch()) {
  if (entry.type === "custom" && entry.customType === MARKER_TYPE) {
   const m = markerMode(entry.data);
   if (m) mode = m;
  }
 }
 if (mode) {
  shared.pinnedMode = mode;
  return;
 }
 const picked = pick(shared);
 shared.pinnedMode = picked;
 pi.appendEntry(MARKER_TYPE, { mode: picked, at: new Date().toISOString(), reason: "session-start" } satisfies PinMarker);
}

// ── Display helpers ─────────────────────────────────────────

function fmtValue(v: string | string[] | null): string {
 if (v === null) return "(未写入)";
 return Array.isArray(v) ? v.join("; ") : v;
}

// ── Extension ───────────────────────────────────────────────

export default function(pi: ExtensionAPI) {
 pi.setLabel("DsPeak");

 const shared = sharedState();
 /** 进程内首个会话认领 owner（主会话的 session_start 必然先于任何 subagent）。 */
 const isOwner = !shared.ownerClaimed && (shared.ownerClaimed = true);

 /** 钉住 peak 时告知本会话各钉住角色实际解析到的 spec（含闸门兜底后的真实值）。 */
 function notifyPinnedMode(ctx: ExtensionContext): void {
  if (shared.pinnedMode !== "peak") return;
  const parts = [...shared.roleManaged.entries()]
   .filter(([key]) => key !== "task")
   .map(([key, entry]) => `${key}→${fmtValue(entry.lastWritten)}`);
  if (parts.length === 0) return;
  ctx.ui.notify(
   `dspeak: DeepSeek 高峰时段（UTC 01:00-04:00 / 06:00-10:00，北京时间周末全天低谷），本会话锚定 peak 分支：${parts.join(", ")}`,
   "info",
  );
 }

 // ── Session lifecycle ───────────────────────────────────

 pi.on("session_start", async (_event, ctx) => {
  if (isOwner) {
   // 钉住判定不依赖额度（闸门在每次 apply 时执行），但提前刷新让首个 apply 即准确。
   await refreshQuotas(pi, ctx, shared, true);
   rebuildPin(pi, ctx, shared);
   applyOverrides(pi, ctx, shared);
   notifyPinnedMode(ctx);
   // 心跳:保证空闲跨过高峰边界/额度迁移后,下一个新 subagent 拿到当下判定。
   ctx.setInterval(() => {
    void refreshQuotas(pi, ctx, shared).then(() => applyOverrides(pi, ctx, shared));
   }, 60_000);
  } else {
   // subagent 实例:只收敛浮动键(pinnedMode 已由 owner 写入注册表)。
   applyOverrides(pi, ctx, shared);
   void refreshQuotas(pi, ctx, shared).then(changed => {
    if (changed) applyOverrides(pi, ctx, shared);
   });
  }
 });

 // 会话内切换/分支/历史导航：branch 继承 marker；switch 换分支后按新分支重建。
 const rebind = async (_event: unknown, ctx: ExtensionContext) => {
  if (!isOwner) return;
  await refreshQuotas(pi, ctx, shared);
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
  if (quotaNeedsRefresh(pi.pi.settings, shared)) {
   void refreshQuotas(pi, ctx, shared).then(changed => {
    if (changed) applyOverrides(pi, ctx, shared);
   });
  }
  applyOverrides(pi, ctx, shared);
 });

 // 主会话每个 turn 开始刷新一次浮动键与额度（覆盖 vibe/runtime 等其他 spawn 路径）。
 pi.on("turn_start", async (_event, ctx) => {
  if (!isOwner) return;
  await refreshQuotas(pi, ctx, shared);
  applyOverrides(pi, ctx, shared);
 });

 pi.on("session_shutdown", async () => {
  if (isOwner) shared.ownerClaimed = false;
 });

 // ── Command: /dspeak ────────────────────────────────────

 pi.registerCommand("dspeak", {
  description: "DeepSeek 高峰避让：/dspeak peak|offpeak|auto|status（别名 luna→peak，flash→offpeak）",
  handler: async (args, ctx) => {
   const sub = (args.trim().split(/\s+/)[0] ?? "").toLowerCase() || "status";
   await refreshQuotas(pi, ctx, shared, true);

   const anchorMap: Record<string, Mode | null> = {
    peak: "peak",
    luna: "peak",
    offpeak: "offpeak",
    flash: "offpeak",
    auto: null,
    clear: null,
    off: null,
   };
   if (Object.hasOwn(anchorMap, sub)) {
    shared.anchor = anchorMap[sub]!;
    if (isOwner) {
     // 显式锚定：立即 re-pin 当前会话并写 marker（resume 后保持）。
     shared.pinnedMode = pick(shared);
     pi.appendEntry(MARKER_TYPE, {
      mode: shared.pinnedMode,
      at: new Date().toISOString(),
      reason: `anchor:${sub}`,
     } satisfies PinMarker);
    }
    applyOverrides(pi, ctx, shared);
    const anchorText = shared.anchor ? `锚定 ${shared.anchor}` : "自动（按 UTC 高峰窗）";
    ctx.ui.notify(`dspeak: ${anchorText}；本会话角色 → ${shared.pinnedMode}，新 subagent → ${pick(shared)}`, "info");
    return;
   }

   if (sub !== "status") {
    ctx.ui.notify(`dspeak: 未知参数 "${sub}"。用法：/dspeak peak|offpeak|auto|status（别名 luna|flash）`, "error");
    return;
   }

   const now = new Date();
   const hhmm = `${String(now.getUTCHours()).padStart(2, "0")}:${String(now.getUTCMinutes()).padStart(2, "0")}`;
   const peak = isPeakUtc(Date.now());
   const quotaLines = [...shared.quota.entries()].map(
    ([base, e]) => `  ${base}: ${e.state === "exhausted" ? "耗尽(周窗口)" : e.state === "ok" ? "可用" : "未知(查询失败放行)"}`,
   );
   const roleLines = [...shared.roleManaged.entries()].map(([k, e]) => `  ${k} → ${fmtValue(e.lastWritten)}`);
   const agentLines = [...shared.agentManaged.entries()].map(([k, e]) => `  ${k} → ${fmtValue(e.lastWritten)}`);
   const lines = [
    `UTC ${hhmm} — ${peak ? "高峰时段" : "非高峰时段"}（窗口 01:00-04:00 / 06:00-10:00 UTC，北京时间周末全天低谷）`,
    `锚定: ${shared.anchor ?? "无"} | 本会话角色: ${shared.pinnedMode} | 新 subagent: ${pick(shared)}`,
    `额度:\n${quotaLines.join("\n") || "  (无 openai-codex 分支)"}`,
    `托管 modelRoles:\n${roleLines.join("\n") || "  无"}`,
    `托管 agentModelOverrides:\n${agentLines.join("\n") || "  无"}`,
   ];
   ctx.ui.notify(lines.join("\n"), "info");
  },
 });
}
