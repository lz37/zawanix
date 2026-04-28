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
            vivaldi = pkgs.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
            };
            opencode = let
              origin = inputs.opencode.packages.${system};
              registryUrl = nixpkgsConfig.npmRegistryOverrides."registry.npmjs.org" or null;
              patchedNodeModules = origin.opencode.node_modules.overrideAttrs (_nmOld: {
                BUN_CONFIG_REGISTRY = registryUrl;
              });
            in
              if registryUrl != null
              then origin.opencode.override {node_modules = patchedNodeModules;}
              else origin.opencode;
            mcp-nixos = prev.mcp-nixos.override {
              python3Packages = prev.python3Packages.overrideScope (pyFinal: pyPrev: {
                aioboto3 = pyPrev.aioboto3.overrideAttrs (old: {
                  disabledTests =
                    (old.disabledTests or [])
                    ++ [
                      "test_dynamo_resource_query"
                      "test_dynamo_resource_put"
                      "test_dynamo_resource_batch_write_flush_on_exit_context"
                      "test_dynamo_resource_batch_write_flush_amount"
                      "test_flush_doesnt_reset_item_buffer"
                      "test_dynamo_resource_property"
                      "test_dynamo_resource_waiter"
                    ];
                });
              });
            };
            openldap = master.openldap;
          }
        )
      ];
    };
  }
)
moduleArgs
