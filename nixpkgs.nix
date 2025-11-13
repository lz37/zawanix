{
  lib,
  inputs,
  system,
  isNvidiaGPU,
  amd64Microarchs,
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
      (
        final: prev: let
          pkgs = prev;
        in rec {
          pkgs___amd64Microarchs = pkgs."pkgs${amd64Microarchs}";
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
          vscode-selected = master.vscode.override {useVSCodeRipgrep = true;};
          vscode-selected-extensionsCompatible = (
            (pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected)
          );
          teleport = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          image-cut = input: pkgs.callPackage ./nixpkgs-build/image-cut.nix input;
          intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
          waylrc = inputs.waylrc.packages.${system}.waylrc;
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
          qq = master.qq;
          feishu = master.feishu.override {
            commandLineArgs = ''
              "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
            '';
          };
          wemeet = master.wemeet;
          wechat = master.wechat;
          jellyfin-media-player = stable.jellyfin-media-player;
          quickshell = inputs.quickshell.packages.${system}.quickshell;
          scx = master.scx;
          distrobox = pkgs.distrobox_git;
          lan-mouse = pkgs.lan-mouse_git;
          kdePackages =
            pkgs.kdePackages
            // {
              wallpaper-engine-plugin = stable.kdePackages.wallpaper-engine-plugin;
            };
        }
      )
    ];
  };
}
