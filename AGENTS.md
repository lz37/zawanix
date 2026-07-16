# Repository Guidelines

## Project Overview

个人 NixOS Flake 桌面环境配置，管理 **4 台主机**（fubuki / thinkbook / work / glap），覆盖 NixOS 系统配置、Home Manager 用户环境、Hyprland/Plasma 桌面、VS Code 深度集成、AI 编码工具（OMP / OpenCode）、内核编译及 CI/CD。

关键特性：
- 全 Flake 化，使用 `flake-parts` 模块化组织
- 硬件自检测（`nixos-facter` → 自动推导 GPU/CPU/SSD 等标记）
- 每台主机独立编译 CachyOS 优化内核
- 通过 Home Manager 管理 100+ 用户级程序配置
- 5 个自定义 OMP TypeScript 扩展（safety-net、direnv、wakatime、commit-tool、omp-pty）
- 18 个 MCP 服务端集成

## Architecture & Data Flow

```
flake.nix (entry)
  ├── inputs: 27+ flake inputs (nixpkgs unstable/stable/master, home-manager, flake-parts, ...)
  │
  ├── nixpkgs.nix — shared pkgs config (allowUnfree, CUDA/ROCm, overlays)
  │     └── applied both in NixOS and home-manager contexts
  │
  ├── options/default.nix — custom zerozawa.* option tree
  │     └── consumed by system/, hardware/, home/ modules
  │
  ├── common/facter-derived.nix — hardware detection pure functions
  │     └── consumes facter JSON → produces flags (isLaptop, isSSD, microarch...)
  │
  ├── system/ — NixOS system modules (kernel, services, packages, virtualisation)
  ├── hardware/ — per-host autodetection + nixos-hardware imports
  ├── network/ — per-host network configs (dynamically loaded by hostname)
  ├── home/zerozawa/ — Home Manager user modules (100+ programs)
  └── .github/workflows/ — CI: kernel build → Cachix push
```

**Data flow:** `facter JSON → facter-derived.nix (flags) → options/default.nix (option defaults) → system/ & home/ modules (consume options)`

**私密配置**：`zerozawa-private` flake input（git+ssh）注入密钥和敏感选项，CI 中 stub 替换。

## Key Directories

| Directory | Purpose | Key patterns |
|-----------|---------|--------------|
| `system/` | NixOS 系统模块 (26+ files) | 单文件模块，`lib.mkIf` 条件逻辑，`config.zerozawa.*` 引用 |
| `system/kernel.nix` | 内核编译参数 | CachyOS 内核 overlay，LTO/bore/bbr3/hugepages 配置 |
| `system/packages/` | 系统包分 9 个子文件 | base / tools / gui / game-editor / hardware / nur / plasma 等 |
| `system/virtualisation/` | 虚拟化配置 | libvirtd + waydroid + nvidia-container-toolkit + oci-containers |
| `hardware/` | 硬件适配入口 | 动态加载 facter，按主机名条件导入 nixos-hardware |
| `network/` | 网络配置 | 按主机名动态 import `<hostName>.nix` |
| `home/zerozawa/` | 用户级配置（~35+ 子模块） | 每文件一程序，`programs.<name>.enable = true` 模式 |
| `home/zerozawa/vscode/` | VS Code 扩展配置 | 按 topic 分 20+ 子配置，merge 工具合入 |
| `home/zerozawa/hyprland/` | Hyprland 桌面 | Nix 生成 Lua 配置，`home.activation` 部署 |
| `home/zerozawa/ai/` | AI 工具 | OMP + OpenCode + MCP(18 servers) + PCTX |
| `home/zerozawa/ai/omp/agent/extensions/` | OMP TypeScript 扩展 | 5 个自定义 `pi.registerTool()` 扩展 |
| `options/` | 自定义选项树 | 单文件 `zerozawa.*` 命名空间 |
| `common/` | 共享工具函数 | `facter-derived.nix` 硬件推导 |
| `.github/workflows/` | CI/CD | 矩阵构建 4 主机内核 |

## Development Commands

```bash
# 构建/切换系统
sudo nixos-rebuild switch --flake .#zawanix-fubuki

# 仅测试用户配置（无需 root）
home-manager switch --flake .#zerozawa

# 构建指定主机内核
nix build .#kernel-zawanix-fubuki

# 更新 flake lock
nix flake update

# 开发环境（devenv）
nix develop

# CI 模拟（本地构建内核）
nix build .#kernel-zawanix-fubuki --no-link --print-build-logs

# 代码格式化
treefmt              # 按 treefmt.nix 配置格式化（alejandra for Nix, shellcheck for scripts）

# 预提交检查
nix flake check      # 等效于 CI 中的 pre-commit 钩子
```

## Code Conventions & Common Patterns

### Nix

- **模块结构**：函数式 `{ pkgs, config, lib, ... }: { ... }`，**禁止** `with lib;` — 所有 lib 函数显式限定（`lib.mkIf`、`lib.optionals`、`lib.mkDefault`）
- **文件命名**：kebab-case（`facter-derived.nix`、`build-kernels.yml`、`away-from-home`）
- **条件逻辑**：`lib.mkIf config.zerozawa.hardware.isNvidiaGPU { ... }`
- **主机标记**：`config.zerozawa.host.isGameMachine`（有 dGPU 时自动设 true）、`config.zerozawa.away-from-home`（笔记本时自动设 true）
- **选项组织**：所有自定义选项在 `options/default.nix` 中 `zerozawa.*` 命名空间，函数式无状态
- **硬件检测**：`common/facter-derived.nix` 导出 `flags` attrset，纯函数无副作用
- **动态 import**：`import ./${hostName}.nix` 模式在 hardware/ 和 network/ 中使用

### Nixpkgs

- **allowUnfree = true**
- **CUDA/ROCm** 条件启用（检测 GPU vendor）
- **NPM registry** → Tencent Cloud 镜像（`registry.npmjs.org` → `mirrors.tencent.com/npm/`）
- **nixpkgs 源** → CERNET 镜像（`mirrors.cernet.edu.cn`）
- **Cachix** 缓存：`zerozawa.cachix.org` + NixOS 官方 + 多个上游

### TypeScript (OMP Extensions)

- **运行环境**：Bun（package.json 中 `@types/bun`，无 Node.js `@types/node` 依赖）
- **扩展注册**：所有扩展在 `config.yml` 的 `extensions` 列表中声明，每个文件 `import` 并注册
- **工具注册**：`pi.registerTool({ name, description, parameters, execute })`
- **Hook 系统**：safety-net 和 wakatime 通过工具调用 hook 工作，非直接 tool 注册
- **命令行 PTY**：所有 PTY 操作通过 `omp-pty.ts` 的 5 个工具（spawn/write/read/list/kill）
- **commit 工具**：Zod schema 校验输入参数，支持 multi-stage 提交
- **Co-authored-by**：所有 commit 自动追加 `OH-MY-PI <omp@can.ac>`
- **测试**：Bun 原生 test runner（`bun test`），2 个测试文件

### OMP Config Patterns

- **memory**：`hindsight` 后端，`per-project-tagged` 范围，mental model `autoSeed = true`
- **modelRoles**：OpenAI codex 承担重任务（default/vision/plan/designer），DeepSeek flash 承担轻任务（task/scout/librarian）
- **agentModelOverrides**：file-analyzer/project-scanner/scout → flash（省钱）；architecture-analyzer/graph-reviewer/tour-builder/designer → codex-sol
- **edit.mode**：`hashline`（非 patch）
- **LSP**：diagnostics on edit, format on write

## Important Files

| File | Role |
|------|------|
| `flake.nix` | **项目入口** — 定义所有 inputs、hosts、packages、devshell |
| `options/default.nix` | **选项树** — 全局 `zerozawa.*` 选项定义 |
| `nixpkgs.nix` | **包管理** — nixpkgs 配置 + overlays（双上下文模式） |
| `common/facter-derived.nix` | **硬件检测** — facter JSON 解析，生成机器特征标记 |
| `system/kernel.nix` | **内核配置** — CachyOS overlay + LTO/调度器/大页 |
| `system/default.nix` | **系统模块入口** — import 26 个子模块 |
| `hardware/default.nix` | **硬件适配入口** — 动态加载 facter + nixos-hardware |
| `home/zerozawa/default.nix` | **用户配置入口** — import ~35 子模块 |
| `home/zerozawa/ai/mcp.nix` | **MCP 服务端注册** — 18 个 MCP 工具 |
| `home/zerozawa/vscode/default.nix` | **VS Code 配置** — 20+ topic 配置 merge |
| `home/zerozawa/hyprland/default.nix` | **Hyprland 桌面** — Lua 配置部署 |
| `home/zerozawa/ai/omp/agent/config.yml` | **OMP 引擎配置** — model roles, extensions, features |
| `home/zerozawa/ai/omp/agent/extensions/safety-net.ts` | **安全网** — 破坏性命令拦截 |
| `home/zerozawa/ai/omp/agent/mcp.json` | **MCP 外部服务注册** |
| `.github/workflows/build-kernels.yml` | **CI/CD** — 4 主机内核构建 + Cachix 推送 |
| `package.json` | **Bun 项目元数据** — workspaces 含 OMP extensions + plugins |

## Runtime/Tooling Preferences

- **Nix**：Flake 模式，`flake-parts` 组织，最低 NixOS 25.05
- **Node.js / TypeScript**：通过 Bun 运行（`bun.lock` + `@types/bun`），非 Node.js
- **包管理器**：`pnpm`（OMP 插件），`bun`（OMP 扩展），`npm`（CI 产物）
- **格式化**：`treefmt`（`alejandra` for Nix + `shellcheck` for scripts），pre-commit 强制
- **Shell**：ZSH + Powerlevel10k（`profile/.p10k.zsh` lean 风格）
- **编辑器**：VS Code（20+ topic 扩展配置）+ Zed（轻量备选）
- **内核编译**：使用 `nix-cachyos-kernel` overlay，每主机独立 kernel package
- **硬件检测**：`nixos-facter`（JSON 报告），非手动配置
- **容器**：Libvirt + OCI containers + Waydroid（Android）
- **AI 工具**：Oh My Pi (OMP) 为主，OpenCode 为辅，PCTX 私有 MCP 代理

## Testing & QA

- **Nix 语法校验**：`nix flake check`（CI 中自动执行，也触发 pre-commit hooks）
- **代码格式化**：`treefmt --fail-on-change`（CI pre-commit 钩子，不格式化阻止提交）
- **OMP 扩展测试**：Bun test runner，位置 `home/zerozawa/ai/omp/agent/extensions/tests/`
  ```bash
  cd home/zerozawa/ai/omp/agent/extensions && bun test
  ```
- **CI（GitHub Actions）**：仅构建内核，不跑全量系统评估
  - 触发器：push 修改 kernel/hardware/nixpkgs/flake 路径，或每日 06:00 UTC
  - `zerozawa-private` 在 CI 中被 stub 替换（无法 git+ssh 克隆）
  - 构建产物推送至 `zerozawa.cachix.org`
- **验证要求**：Nix 配置修改必须通过 `nix flake check` 语法解析
- **kernel 编译**：不启用 LTO（GCC 15.2 有 ICE），不启用 ccHarder（O3）
- **convention**：不提交无法构建的包、不带过期 FOD hash 的版本更新
