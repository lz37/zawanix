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
      npmRegistryOverrides = {
        "registry.npmjs.org" = "https://registry.npmmirror.com";
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
            nocuda = import inputs.nixpkgs {
              inherit system;
              config =
                nixpkgsConfig
                // {
                  cudaSupport = false;
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
            opencode = inputs.opencode.packages.${system}.opencode;
          }
        )
      ];
    };
  }
)
moduleArgs
