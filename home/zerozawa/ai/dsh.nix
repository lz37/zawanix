{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  dshPackages = inputs.deepseek-harness.packages.${system};
  webProfileDir = "${config.zerozawa.path.cfgRoot}/home/zerozawa/ai/dsh/profiles/web";
in {
  # 只装二进制，不用 programs.dsh 模块。
  #
  # 模块的唯一价值是"由 Nix 声明并播种 profile"：managed 每次启动按指纹回滚，
  # mutable 仅首次播种后冻结（升级不回流）。而 dsh 的 profile 本来就是运行时组合物
  # （profile 名是位置参数：`dsh tui` / `dsh web` / `dsh --profile <name>`），
  # 声明进 Nix 只会得到 播种/回滚/校验 三件事，外加 .nix-managed 指纹校验：
  # 目录一旦被声明，软链会被 `refusing to follow profile symlink` 判死。
  #
  # 纯二进制下所有 profile 归 dsh 自己管，任何一个都能像 ~/.omp 那样整目录软链进仓库
  # （见下面的 web 例子）。shipped bundle（dsh-base / dsh-tui / dsh-web-app /
  # dsh-headless / dsh-notification）由包内 nix-support/dsh-bundles.json 提供 store 路径，
  # 不依赖 Nix 侧 profile 声明，也不会像旧 profiles/node_modules 那样留悬空软链。
  #
  # package 直接引用上游 flake 预编译输出：模块 overlay 注入的 pkgs.dsh.* 会在本地
  # nixpkgs 上重新实例化，drv hash 与上游 CI 不一致 → Cachix 全 miss。
  # 只装 CLI：桌面 app（dsh-desktop-official）用不上——它自带内嵌 runtime，
  # profile 名取 `DSH_NIX_DESKTOP_PROFILE ?? 'desktop'`，与 web profile 天然隔离；
  # 要用再把它加回来。
  home.packages = [
    dshPackages.dsh
  ];

  # web profile：仓库即真源（.gitignore 白名单在 ai/dsh/profiles/web/ 里）。
  #   cordis.patch.yml     人写（密钥/网关地址只放 !!js process.env.* 引用）
  #   package.json         bundle 列表
  #   pnpm-workspace.yaml  常量
  #   cordis.yml           dsh 每次启动重写的解析树，被 gitignore
  home.activation.linkDshWebProfile = lib.hm.dag.entryAfter ["writeBoundary"] ''
    target="$HOME/.dsh/profiles/web"
    if [ ! -L "$target" ] && [ -d "$target" ]; then
      mv "$target" "$target.bak.$(date +%s)"
    fi
    mkdir -p "$HOME/.dsh/profiles"
    ln -sfn ${webProfileDir} "$target"
  '';
}
