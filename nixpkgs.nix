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
    };
  in {
    nixpkgs = {
      config = nixpkgsConfig;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
        inputs.nix-alien.overlays.default
        inputs.nix4vscode.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.llm-agents.overlays.shared-nixpkgs
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
            intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
            nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
            quickshell = inputs.quickshell.packages.${system}.quickshell;
            vivaldi = master.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
              vivaldi-ffmpeg-codecs = master.vivaldi-ffmpeg-codecs;
            };
            mcp-nixos = master.mcp-nixos;
            # upstream oh-my-pi 18.1.20 (rev 1bd60c6) makes
            # packages/coding-agent/src/cli/collab-cli.ts import `chalk`,
            # which is not declared in packages/coding-agent/package.json (it
            # only arrives transitively via dev-only @typescript/analyze-trace).
            # Hoisted installs resolve it anyway; bun2nix builds with
            # `bun install --linker=isolated`, so Bun.build aborts with
            # `Could not resolve: "chalk"`. Swap in pi-utils' in-repo chalk
            # reimplementation (already a declared dependency, same surface).
            # Drop once the omp flake input passes an upstream fix.
            omp = inputs.omp.packages.${system}.omp.overrideAttrs (_old: {
              postPatch = ''
                substituteInPlace packages/coding-agent/src/cli/collab-cli.ts \
                  --replace 'import chalk from "chalk";' 'import chalk from "@oh-my-pi/pi-utils/chalk";'
              '';
            });
          }
        )
      ];
    };
  }
)
moduleArgs
