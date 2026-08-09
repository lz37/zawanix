moduleArgs @ {
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
(
  {osConfig ? null, ...}: let
    systemConfig =
      if osConfig != null
      then osConfig
      else config;
    hw = systemConfig.zerozawa.hardware;
    system = pkgs.stdenv.hostPlatform.system;
    nixpkgsConfig = {
      allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
      allowUnfree = true;
      cudaSupport = hw.isNvidiaGPU;
      rocmSupport = hw.isAmdGPU;
      npmRegistryOverrides = {
        "registry.npmjs.org" = "https://mirrors.cloud.tencent.com/npm/";
      };
    };
  in {
    nixpkgs = {
      config = nixpkgsConfig;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
        inputs.nix-alien.overlays.default
        inputs.nix4vscode.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
        # inputs.hyprland.overlays.default
        # inputs.hyprland.overlays.hyprland-packages
        (
          final: prev: let
            pkgs = prev;
          in rec {
            # 启用 NUR
            nur = import inputs.nur {
              nurpkgs = prev;
              pkgs = prev;
              repoOverrides = {
                zerozawa = import inputs.zerozawa-nur {inherit pkgs;};
              };
            };
            stable = import inputs.nixpkgs-stable {
              inherit system;
              config = nixpkgsConfig;
            };
            master = import inputs.nixpkgs-master {
              inherit system;
              config = nixpkgsConfig;
            };
            nogpu = import inputs.nixpkgs {
              inherit system;
              config =
                nixpkgsConfig
                // {
                  cudaSupport = false;
                  rocmSupport = false;
                };
              overlays = [
                (final: prev: {
                  nur = import inputs.nur {
                    nurpkgs = prev;
                    pkgs = prev;
                  };
                })
              ];
            };
            vscode-selected = master.vscode.override {
              # commandLineArgs = "--disable-features=WaylandWpColorManagerV1";
            };
            vscode-selected-extensionsCompatible =
              ((pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected))
              // {
                forVscode = pkgs.nix4vscode.forVscodeVersion (lib.getVersion vscode-selected);
                forVscodePrerelease = pkgs.nix4vscode.forVscodeVersionPrerelease (lib.getVersion vscode-selected);
                forOpenVsx = pkgs.nix4vscode.forOpenVsxVersion (lib.getVersion vscode-selected);
                forOpenVsxPrerelease = pkgs.nix4vscode.forOpenVsxVersionPrerelease (lib.getVersion vscode-selected);
              };
            # nixpkgs PR #549253 未进 unstable：glaze 已升 8.0.0 但 hyprland 0.56.1 仍要求
            # find_package(glaze 7...<8)，回退 FetchContent 克隆（沙箱无 git）导致构建失败。
            # 抄上游修法：放宽 glaze 版本约束。全局 override 让 grimblast 等传递依赖也生效。
            hyprland = prev.hyprland.overrideAttrs (old: {
              postPatch =
                (old.postPatch or "")
                + ''
                  substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
                    --replace "glaze 7...<8" "glaze"
                '';
            });
            intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
            nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
            quickshell = inputs.quickshell.packages.${system}.quickshell;
            vivaldi = master.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
              vivaldi-ffmpeg-codecs = master.vivaldi-ffmpeg-codecs;
            };
            opencode = master.opencode;
            mcp-nixos = master.mcp-nixos;
          }
        )
      ];
    };
  }
)
moduleArgs
