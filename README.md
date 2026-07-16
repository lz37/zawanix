# zerozawa's NixOS Config

基于 [NixOS Flake](https://nixos.wiki/wiki/Flakes) + [Home Manager](https://github.com/nix-community/home-manager) 的个人桌面环境配置。

## 目录结构

```
.
├── flake.nix              # Flake 入口，定义 inputs / outputs
├── options/               # 自定义 NixOS module options
├── common/                # 共享工具函数
├── system/                # NixOS 系统级配置
│   ├── kernel.nix         # 内核编译参数（LTO、CPU 优化、调度器等）
│   ├── default.nix        # 系统配置入口
│   ├── packages/          # 按类别分组的系统包
│   ├── virtualisation/    # 虚拟化（Libvirt、Waydroid、OCI 容器）
│   ├── mihomo/            # Mihomo 代理客户端
│   └── ...
├── hardware/              # 硬件配置
│   ├── hostname/          # 按主机名的硬件配置
│   ├── facter/            # nixos-facter 生成的硬件描述
│   └── nvidia/            # NVIDIA GPU 配置
├── network/               # 网络接口配置（多主机）
├── home/zerozawa/         # Home Manager 用户配置
│   ├── default.nix        # 用户配置入口
│   ├── hyprland/          # Hyprland 窗口管理器（含 Lua 配置）
│   ├── plasma/            # KDE Plasma 桌面配置
│   ├── vscode/            # VS Code 扩展按 topic 组织
│   ├── ai/                # AI 工具（OMP、OpenCode、PCTX）
│   │   └── omp/agent/extensions/  # OMP 助手扩展（TypeScript）
│   ├── zsh/               # ZSH 配置
│   ├── yazi/              # Yazi 文件管理器
│   └── ...
├── stylix/                # StyLix 主题引擎
├── profile/               # Shell profile 配置
└── .github/workflows/     # CI/CD - 多机内核构建
```

## 架构

### 主机

| 主机 | 角色 | CPU | GPU |
|------|------|-----|-----|
| fubuki | 主力桌面 | AMD 9800X3D | RTX 5080 |
| thinkbook | 笔记本 | Intel | NVIDIA eGPU (OCuLink) |
| glap | 轻薄本 | Intel | 集成显卡 |
| work | 办公机 | - | - |

### 内核

每台主机独立编译内核，使用 [nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel) 作为基础：

- **fubuki**: `processorOpt = "zen4"`, `cpusched = "bore"`, `hugepage = "always"`
- **ThinkBook**: `GENERIC_CPU`, 通用优化

CI（GitHub Actions）自动编译各机内核并推送到 Cachix。

### 桌面

- **Hyprland** — 主力桌面，Lua 配置化（按键绑定、动画、监视器布局）
- **KDE Plasma** — 备用桌面
- **Openbox** — 轻量备选

### AI 工具集成

- [Oh My Pi](https://ohmypi.com) — AI 编码助手，含自定义 TypeScript 扩展（safety-net、direnv、wakatime 等）
- [OpenCode](https://github.com/anomalyco/opencode) — 终端 AI 编码
- [PCTX](https://github.com/zerozawa/pctx) — 私有上下文 MCP 代理

## 使用

```bash
# 构建系统
sudo nixos-rebuild switch --flake .#zawanix-fubuki

# 仅测试用户配置
home-manager switch --flake .#zerozawa

# 构建内核（CI 用）
nix build .#kernel-fubuki

# 更新依赖
nix flake update
```

首次部署或换机需在 `options/` 中配置变量（如用户名、邮箱等）。
