import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: litellm-image — 注册 LiteLLM 网关的图像模型，并把「改图」请求
 * 整形到订阅真正支持的那条接口上。
 *
 * 背景一（注册）：网关侧 gpt-image-2 组是 `image_generation` 模式，被 litellm 的
 * `exclude-discovery-modes` 排除（OMP 不会从 /model_group/info 发现它）；
 * 而 `models.yml` 里静态声明 `models:` 时 schema 强制要求字面 `baseUrl`
 * （`validateProviderConfiguration`），且 baseUrl 不做环境变量展开
 * （`resolveConfigValue` 只作用于 apiKey/headers）。把网关地址写进仓库不可接受，
 * 所以改在运行期注册：地址与密钥都从 `LITELLM_BASE_URL` / `LITELLM_API_KEY`
 * 读取，与 litellm 动态发现的默认来源完全一致。
 *
 * 背景二（改图）：OMP 对 `provider !== "openai"` 的模型固定打
 * `POST /v1/images/edits`（JSON `input_references`），而网关里 chatgpt 组没有
 * `/images/edits` 实现，会回 `image edit is not supported for chatgpt`。
 * 订阅真正的改图能力在 Codex `/v1/responses` 的
 * `tools:[{type:"image_generation", action:"edit"}]` 里，LiteLLM 会把 `tools`
 * 原样透传（`chatgpt/responses/transformation.py` 的 allowed_keys）。
 *
 * 做法：扩展在 127.0.0.1 起一个极小的反代，provider 的 baseUrl 指向它。
 *   - `/v1/images/edits` 且带参考图 → 改写为上游 `/responses` 工具调用，
 *     再把 `image_generation_call.result` 合成为 `{data:[{b64_json}]}`
 *   - 其余请求原样透传到 `LITELLM_BASE_URL`（生成、模型列表、报错都走这里）
 * 之所以不直接改 `globalThis.fetch`：OMP 的图像调用会用工具层自带的 fetch
 * 实现（`options.fetch`），进程级 patch 拦不到。
 *
 * 环境变量：
 *   LITELLM_BASE_URL             必填，网关 /v1 地址（不含结尾斜杠）
 *   LITELLM_API_KEY              必填，网关 key
 *   LITELLM_IMAGE_EDIT_CARRIER   可选，Responses 载体模型，默认 gpt-6.2-sol
 *   LITELLM_IMAGE_EDIT_FORMAT    可选，输出格式，默认 webp
 *
 * 上游行为（2026-11 实测）：Codex 的 images 路由忽略 size/quality，固定返回
 * 1536x1024（1.57MP）横图，需要精确像素时本地缩放。
 */
const CARRIER = process.env.LITELLM_IMAGE_EDIT_CARRIER ?? "gpt-6.2-sol";
const OUTPUT_FORMAT = process.env.LITELLM_IMAGE_EDIT_FORMAT ?? "webp";

const LOCAL_SERVER = Symbol.for("omp.litellm-image.local-server");

type EditPlan = { prompt: string; images: string[] };

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

function bytesToDataUrl(bytes: Uint8Array, mime: string): string {
	return `data:${mime};base64,${Buffer.from(bytes).toString("base64")}`;
}

function sniffMime(bytes: Uint8Array): string {
	if (bytes[0] === 0x89 && bytes[1] === 0x50) return "image/png";
	if (bytes[0] === 0xff && bytes[1] === 0xd8) return "image/jpeg";
	if (bytes[0] === 0x47 && bytes[1] === 0x49) return "image/gif";
	if (bytes[0] === 0x52 && bytes[1] === 0x49) return "image/webp";
	return "image/png";
}

/** 收集表单/JSON 里的参考图，统一成 data URL。 */
async function collectReferences(value: unknown): Promise<string[]> {
	if (typeof value === "string") {
		if (value.startsWith("data:")) return [value];
		const raw = Buffer.from(value, "base64");
		return [bytesToDataUrl(raw, sniffMime(raw))];
	}
	if (Array.isArray(value)) {
		const all: string[] = [];
		for (const item of value) all.push(...(await collectReferences(item)));
		return all;
	}
	if (value instanceof Blob) {
		const bytes = new Uint8Array(await value.arrayBuffer());
		return [bytesToDataUrl(bytes, value.type || sniffMime(bytes))];
	}
	return [];
}

/** 解析 OMP 发出的 /images/edits 请求体（JSON 或 multipart）。 */
async function parseEditRequest(body: unknown): Promise<EditPlan | null> {
	if (!body) return null;
	if (typeof body === "string") {
		try {
			const json: unknown = JSON.parse(body);
			if (!isRecord(json)) return null;
			const images = await collectReferences(json.input_references ?? json.images ?? json.image);
			if (!images.length) return null;
			return { prompt: String(json.prompt ?? ""), images };
		} catch {
			return null;
		}
	}
	if (body instanceof FormData) {
		const prompt = String(body.get("prompt") ?? "");
		const images: string[] = [];
		for (const [key, value] of body.entries()) {
			if (key !== "image" && key !== "image[]") continue;
			images.push(...(await collectReferences(value)));
		}
		if (!images.length) return null;
		return { prompt, images };
	}
	return null;
}

/** 从 Responses 的 JSON 或 SSE 响应里取回 b64 图片。 */
function extractImages(payload: unknown): string[] {
	const found: string[] = [];
	const visit = (value: unknown): void => {
		if (Array.isArray(value)) {
			for (const item of value) visit(item);
			return;
		}
		if (!isRecord(value)) return;
		if (value.type === "image_generation_call" && typeof value.result === "string") {
			found.push(value.result);
		}
		for (const key of ["output", "response", "data", "item"]) {
			if (key in value) visit(value[key]);
		}
	};
	visit(payload);
	return found;
}

function parseSse(text: string): unknown[] {
	const events: unknown[] = [];
	for (const line of text.split("\n")) {
		const trimmed = line.trim();
		if (!trimmed.startsWith("data:")) continue;
		const data = trimmed.slice(5).trim();
		if (!data || data === "[DONE]") continue;
		try {
			events.push(JSON.parse(data));
		} catch {
			// 半截帧或非 JSON 事件，忽略
		}
	}
	return events;
}

function imageResponse(images: string[]): Response {
	return new Response(
		JSON.stringify({ created: Math.floor(Date.now() / 1000), data: images.map((b64) => ({ b64_json: b64 })) }),
		{ status: 200, headers: { "content-type": "application/json" } },
	);
}

/** 把一次 /images/edits 改写成上游 /responses 的 image_generation 工具调用。 */
async function editViaResponses(upstream: string, request: Request, plan: EditPlan): Promise<Response> {
	const body = {
		model: CARRIER,
		input: [
			{
				role: "user",
				content: [
					{ type: "input_text", text: plan.prompt },
					...plan.images.map((url) => ({ type: "input_image", detail: "auto", image_url: url })),
				],
			},
		],
		tools: [{ type: "image_generation", action: "edit", output_format: OUTPUT_FORMAT }],
		tool_choice: { type: "image_generation" },
		store: false,
	};
	const headers: Record<string, string> = {
		"content-type": "application/json",
		accept: "text/event-stream, application/json",
	};
	const authorization = request.headers.get("authorization");
	if (authorization) headers.authorization = authorization;

	const response = await fetch(`${upstream.replace(/\/+$/, "")}/responses`, {
		method: "POST",
		headers,
		body: JSON.stringify(body),
	});
	if (!response.ok) return response;

	const text = await response.text();
	const contentType = response.headers.get("content-type") ?? "";
	const payloads = contentType.includes("text/event-stream") ? parseSse(text) : [text ? JSON.parse(text) : {}];
	const images = payloads.flatMap((payload) => extractImages(payload));
	if (!images.length) {
		return new Response(
			JSON.stringify({ error: { message: "responses returned no image_generation_call", type: "upstream_error" } }),
			{ status: 502, headers: { "content-type": "application/json" } },
		);
	}
	return imageResponse(images);
}

async function forward(upstream: string, request: Request, pathname: string): Promise<Response> {
	const target = `${upstream.replace(/\/+$/, "")}${pathname.replace(/^\/v1/, "")}`;
	const headers = new Headers(request.headers);
	headers.delete("host");
	headers.delete("content-length");
	const init: RequestInit = { method: request.method, headers };
	if (request.method !== "GET" && request.method !== "HEAD") init.body = await request.arrayBuffer();
	return fetch(target, init);
}

type BunServe = (options: {
	hostname?: string;
	port?: number;
	fetch: (request: Request) => Promise<Response> | Response;
}) => { port: number; stop: () => void };

async function handle(upstream: string, request: Request): Promise<Response> {
	const { pathname } = new URL(request.url);
	if (pathname.endsWith("/images/edits")) {
		const contentType = (request.headers.get("content-type") ?? "").toLowerCase();
		const raw: unknown = contentType.includes("application/json")
			? await request.text()
			: await request.formData();
		const plan = await parseEditRequest(raw);
		if (plan) return editViaResponses(upstream, request, plan);
	}
	return forward(upstream, request, pathname);
}

export const __test = { parseEditRequest, extractImages, parseSse, collectReferences };

export default function(pi: ExtensionAPI) {
	const upstream = process.env.LITELLM_BASE_URL;
	if (!upstream) return;

	const globalScope = globalThis as typeof globalThis & { [LOCAL_SERVER]?: { port: number } };
	let local = globalScope[LOCAL_SERVER];
	if (!local) {
		// Bun 运行时的 serve；@types/bun 只在 workspace 根，这里用最小接口命名后再访问
		const bunRuntime = globalThis as unknown as { Bun: { serve: BunServe } };
		const serve = bunRuntime.Bun.serve;
		const server = serve({
			hostname: "127.0.0.1",
			port: 0,
			fetch: (request: Request) => handle(upstream, request),
		});
		local = { port: server.port };
		globalScope[LOCAL_SERVER] = local;
	}

	pi.registerProvider("litellm-image", {
		baseUrl: `http://127.0.0.1:${local.port}/v1`,
		apiKey: "LITELLM_API_KEY",
		models: [
			{
				id: "gpt-image-2",
				name: "GPT Image 2",
				api: "openai-images",
				kind: "image",
				reasoning: false,
				input: ["text", "image"],
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
				contextWindow: 10000,
				maxTokens: 16384,
			},
		],
	});
}
