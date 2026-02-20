{
  lib,
  inputs,
  system,
  isNvidiaGPU,
  ...
}: let
  config = {
    allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
    allowUnfree = true;
    cudaSupport = isNvidiaGPU;
  };
in {
  nixpkgs = {
    inherit config;
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
            repoOverrides = {zerozawa = import inputs.zerozawa-nur {inherit pkgs;};};
          };
          stable = import inputs.nixpkgs-stable {
            inherit system config;
          };
          master = import inputs.nixpkgs-master {
            inherit system config;
          };
          nocuda = import inputs.nixpkgs {
            inherit system;
            config =
              config
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
            useVSCodeRipgrep = true;
            commandLineArgs = "--disable-features=WaylandWpColorManagerV1";
          };
          vscode-selected-extensionsCompatible =
            (
              (pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected)
            )
            // {
              forVscode = pkgs.nix4vscode.forVscodeVersion (lib.getVersion vscode-selected);
              forVscodePrerelease = pkgs.nix4vscode.forVscodeVersionPrerelease (lib.getVersion vscode-selected);
              forOpenVsx = pkgs.nix4vscode.forOpenVsxVersion (lib.getVersion vscode-selected);
              forOpenVsxPrerelease = pkgs.nix4vscode.forOpenVsxVersionPrerelease (lib.getVersion vscode-selected);
            };
          teleport = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
          nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
          unstable-hyprland = {
            packages = inputs.hyprland.packages.${system};
            pkgs = import inputs.hyprland.inputs.nixpkgs {
              inherit system config;
            };
            plugins = {
              inherit (inputs.split-monitor-workspaces.packages.${system}) split-monitor-workspaces;
              inherit (inputs.hypr-dynamic-cursors.packages.${system}) hypr-dynamic-cursors;
              inherit (inputs.hyprfocus.packages.${system}) hyprfocus;
              inherit
                (inputs.hyprland-plugins.packages.${system})
                borders-plus-plus
                csgo-vulkan-fix
                hyprbars
                hyprexpo
                # hyprfocus
                hyprscrolling
                hyprtrails
                hyprwinwrap
                xtra-dispatchers
                ;
            };
          };
          quickshell = inputs.quickshell.packages.${system}.quickshell;
          opencode-dev-pkgs = inputs.opencode.packages.${system};
        }
      )
    ];
  };
}
