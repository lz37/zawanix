import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: litellm-image — 注册 LiteLLM 网关的图像模型，并把生图/改图请求
 * 直接发到订阅真正支持的那条接口上。
 *
 * 背景一（注册）：网关侧 gpt-image-2 组是 `image_generation` 模式，被 litellm 的
 * `exclude-discovery-modes` 排除（OMP 不会从 /model_group/info 发现它）；
 * 而 `models.yml` 里静态声明 `models:` 时 schema 强制要求字面 `baseUrl`
 * （`validateProviderConfiguration`），且 baseUrl 不做环境变量展开
 * （`resolveConfigValue` 只作用于 apiKey/headers）。把网关地址写进仓库不可接受，
 * 所以改在运行期注册：地址与密钥都从 `LITELLM_BASE_URL` / `LITELLM_API_KEY`
 * 读取，与 litellm 动态发现的默认来源完全一致。
 *
 * 背景二（生图/改图）：OMP 内置的 `openai-images` 走 `/v1/images/*`，网关里
 * chatgpt 组没有 `/images/edits`，会回 `image edit is not supported for chatgpt`。
 * 订阅真正的能力在 Codex `/v1/responses` 的
 * `tools:[{type:"image_generation", action:"edit"|"generate"}]` 里，LiteLLM 会把
 * `tools` 原样透传（`chatgpt/responses/transformation.py` 的 allowed_keys）。
 *
 * 做法：用 `registerProvider` 的 `generateImage` 钩子接管该 provider 的全部图像
 * 请求（`packages/ai/src/images/index.ts` 里钩子优先于按 api 分派的内置实现），
 * 不经过 `/images/*`，也不需要本地反代。
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
const MAX_IMAGES_PER_CALL = 4;
const DESCEND_KEYS: Record<string, true> = { output: true, response: true, data: true, item: true };

interface ReferenceImage {
	data: string;
	mimeType: string;
}

interface RequestOptions {
	apiKey: unknown;
	fetch?: unknown;
	signal?: AbortSignal;
}

function sniffBase64MimeType(base64: string): string {
	const head = Buffer.from(base64.slice(0, 12), "base64");
	if (head[0] === 0x89 && head[1] === 0x50) return "image/png";
	if (head[0] === 0xff && head[1] === 0xd8) return "image/jpeg";
	if (head[0] === 0x47 && head[1] === 0x49) return "image/gif";
	if (head[0] === 0x52 && head[1] === 0x49) return "image/webp";
	return "image/webp";
}

/** 解析 provider 的 apikey（字面量或解析函数）成请求头里的 bearer。 */
async function resolveBearer(apiKey: unknown, signal?: AbortSignal): Promise<string> {
	if (typeof apiKey === "string") return apiKey;
	if (typeof apiKey !== "function") return "";
	const resolved: unknown = await apiKey({ lastChance: false, error: undefined, signal });
	if (typeof resolved === "string") return resolved;
	if (resolved && typeof resolved === "object") {
		const key = (resolved as { apiKey?: unknown }).apiKey;
		if (typeof key === "string") return key;
	}
	return "";
}

/** 从 Responses 的 JSON 或 SSE 负载里取回 b64 图片；Codex 把它们放在 image_generation_call.result。 */
function extractImages(payload: unknown): string[] {
	const found: string[] = [];
	const visit = (value: unknown): void => {
		if (Array.isArray(value)) {
			for (const item of value) visit(item);
			return;
		}
		if (typeof value !== "object" || value === null) return;
		if ("type" in value && value.type === "image_generation_call" && "result" in value && typeof value.result === "string") {
			found.push(value.result);
		}
		for (const [key, child] of Object.entries(value)) {
			if (DESCEND_KEYS[key]) visit(child);
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

/** 一次 Responses 工具调用，返回其中的 b64 图片。 */
async function requestImages(
	url: string,
	prompt: string,
	references: readonly ReferenceImage[],
	options: RequestOptions,
): Promise<string[]> {
	const content: Array<Record<string, unknown>> = [{ type: "input_text", text: prompt }];
	for (const image of references) {
		content.push({
			type: "input_image",
			detail: "auto",
			image_url: `data:${image.mimeType};base64,${image.data}`,
		});
	}
	const body = {
		model: CARRIER,
		input: [{ role: "user", content }],
		tools: [
			{
				type: "image_generation",
				action: content.length > 1 ? "edit" : "generate",
				output_format: OUTPUT_FORMAT,
			},
		],
		tool_choice: { type: "image_generation" },
		store: false,
	};
	const fetchImpl = typeof options.fetch === "function" ? (options.fetch as typeof fetch) : fetch;
	const bearer = await resolveBearer(options.apiKey, options.signal);
	const response = await fetchImpl(url, {
		method: "POST",
		headers: {
			"content-type": "application/json",
			accept: "text/event-stream, application/json",
			authorization: `Bearer ${bearer}`,
		},
		body: JSON.stringify(body),
		signal: options.signal,
	});
	if (!response.ok) {
		throw new Error(`litellm image request failed (${response.status}): ${(await response.text()).slice(0, 500)}`);
	}
	const text = await response.text();
	const contentType = response.headers.get("content-type") ?? "";
	const payloads = contentType.includes("text/event-stream") ? parseSse(text) : [text ? JSON.parse(text) : {}];
	const images = payloads.flatMap((payload) => extractImages(payload));
	if (!images.length) throw new Error("litellm image response contained no image_generation_call");
	return images;
}

export const __test = { extractImages, parseSse, sniffBase64MimeType, resolveBearer };

export default function(pi: ExtensionAPI) {
	const upstream = process.env.LITELLM_BASE_URL;
	if (!upstream) return;
	const responsesUrl = `${upstream.replace(/\/+$/, "")}/responses`;

	pi.registerProvider("litellm-image", {
		baseUrl: upstream,
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
		generateImage: async (_model, request, options) => {
			const wanted = Math.min(Math.max(request.count ?? 1, 1), MAX_IMAGES_PER_CALL);
			const images: Array<{ data: string; mimeType: string }> = [];
			for (let index = 0; index < wanted; index++) {
				const results = await requestImages(responsesUrl, request.prompt, request.inputImages ?? [], {
					apiKey: options.apiKey,
					fetch: options.fetch,
					signal: options.signal,
				});
				for (const data of results) images.push({ data, mimeType: sniffBase64MimeType(data) });
			}
			return {
				images,
				usage: {
					input: 0,
					output: 0,
					cacheRead: 0,
					cacheWrite: 0,
					totalTokens: 0,
					cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
				},
			};
		},
	});
}
