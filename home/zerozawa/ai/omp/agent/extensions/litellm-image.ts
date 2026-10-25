import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/**
 * OMP Extension: litellm-image — 注册 LiteLLM 网关的图像模型，地址取自环境变量。
 *
 * 背景：网关侧 gpt-image-2 组是 `image_generation` 模式，被 litellm 的
 * `exclude-discovery-modes` 排除（OMP 不会从 /model_group/info 发现它）；
 * 而 `models.yml` 里静态声明 `models:` 时 schema 强制要求字面 `baseUrl`
 * （`validateProviderConfiguration`），且 baseUrl 不做环境变量展开
 * （`resolveConfigValue` 只作用于 apiKey/headers）。把网关地址写进仓库不可接受，
 * 所以改在运行期注册：地址与密钥都从 `LITELLM_BASE_URL` / `LITELLM_API_KEY`
 * 读取，与 litellm 动态发现的默认来源完全一致。
 *
 * 图像角色在 config.yml 里指向 `litellm-image/gpt-image-2`；未设置这两个环境
 * 变量时本扩展不注册任何东西，角色自然不可解析（不会影响其他模型）。
 *
 * 上游行为（2026-10 实测，详见 skill litellm-image-generation）：Codex 的
 * images 路由忽略 size/quality，固定返回 ~1.57MP 画布，形状随 prompt 变化，
 * 需要精确像素时本地缩放。
 */
export default function (pi: ExtensionAPI) {
	const baseUrl = process.env.LITELLM_BASE_URL;
	if (!baseUrl) return;
	pi.registerProvider("litellm-image", {
		baseUrl,
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
