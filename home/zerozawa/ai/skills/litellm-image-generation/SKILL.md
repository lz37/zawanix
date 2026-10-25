---
name: litellm-image-generation
description: "Generate images through the LiteLLM gateway (chatgpt subscription route): size/quality are not honored, output is a fixed ~1.57 MP canvas shaped by the prompt, so post-process for exact pixels; public OpenAI Images API rules differ."
---

# Image generation through the LiteLLM gateway

## When

Any `generate_image` call (or any image request) whose model is a LiteLLM gateway
group backed by the `chatgpt/` provider — typically `litellm/gpt-image-2`, or a
chat group such as `litellm/gpt-6.1-sol` / `litellm/gpt-6-luna` used as a hosted
image carrier. Also when a request "asks for 1024x1024" and the returned PNG is
some other size.

Do not apply these facts to the public `api.openai.com` Images API or to
OpenAI's PAYG image models; their sizing rules are different (see below).

## What the subscription (Codex) route actually does

- Upstream is the Codex image path (`/backend-api/codex/images/generations`, and
  the `image_generation` tool on `/backend-api/codex/responses`).
- Requests are downgraded to `gpt-image-2-codex` with `size: auto` and
  `quality: auto`. The `size` field is accepted but **does not reach the output**;
  `quality` is only partially reflected (low/medium observed, high never).
- Output is a roughly constant pixel budget of **~1.57 MP**, with the aspect
  ratio inferred from the prompt.
- Measured (2026-10, subscription account):

| requested `size` | prompt | returned size | pixels |
|---|---|---|---|
| 1024x1024 / 1536x1024 / 1024x1536 / 2048x2048 | square subject | 1254x1254 | 1,572,516 |
| 1024x1024 | 3:1 ultra-wide panorama | 2172x724 | 1,572,528 |
| 1536x1024 | 3:1 ultra-wide panorama | 2164x727 | 1,568,668 |

  The returned edges (1254, 2172, 724) are not multiples of 16, which is the
  tell that these canvases come from the auto path, not from the documented
  sizing validation. Third-party reports match: OAuth/Codex image requests are
  downgraded to `gpt-image-2-codex` auto/auto and return ~1.5 MP with shapes
  like 1254x1254, 1024x1536, 1693x929 (see sub2api#3302 and the OpenAI
  community thread on subscription resolution control).

## How to work with it

1. Treat the `image_size` argument as a hint only. Shape the canvas through the
   prompt (`subject`): say "3:1 ultra-wide panorama" / "9:16 vertical poster" /
   "square". Measured shapes follow that wording.
2. When an exact pixel size is required, post-process: `magick in.png -resize
   1024x1024! out.png` (or crop to the target aspect first, then resize).
3. Do not report the requested size as the delivered size. Report the measured
   dimensions (`magick identify` / `file`).
4. Never invent a separate image *model* for this provider: LiteLLM's `chatgpt/`
   provider has no standalone image slug. Image generation is either the
   `/v1/images/generations` route on an `image`-kind group that maps to a chat
   deployment, or the Responses `image_generation` tool on a chat model.

## Public OpenAI Images API differs

Only the public API (`api.openai.com`, paid key, models such as `gpt-image-2`)
honors `size`, and it validates:

- `WIDTHxHEIGHT`, both dimensions divisible by 16
- aspect ratio between 1:3 and 3:1
- longest edge < 3840 (above 2560x1440 is experimental)
- total pixels 655,360 – 8,294,400

Standard presets: 1024x1024, 1536x1024, 1024x1536. The Responses API and the
Images API share those rules; the subscription route above does not.

## Wiring facts (if the setup has to be rebuilt)

- LiteLLM 1.106 has a native `chatgpt/` provider: OAuth device flow, token file
  under `CHATGPT_TOKEN_DIR` (single-use refresh token, so every replica must
  share one writable copy — RWX volume), `mode: responses` for chat groups.
- An image-role group is declared as its own model group whose `model` is the
  chat deployment (e.g. `chatgpt/gpt-6.1-sol`) with `mode: image_generation`;
  `/v1/images/generations` then reaches the Codex images path.
- Client side: OMP exposes only `image_size` ∈ {1024x1024, 1536x1024, 1024x1536}
  and seven aspect ratios in the `generate_image` schema; those are hardcoded in
  the tool, not derived from the model, so no client declares pixel limits.
