{
  lib,
  inputs,
  system,
  ...
}: let
  config = {
    allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
    allowUnfree = true;
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
          # 启用 NUR
          nur = import inputs.nur {
            nurpkgs = prev;
            pkgs = prev;
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
          picacg-qt = pkgs.callPackage ./nixpkgs-build/picacg.nix {};
          jmcomic-qt = pkgs.callPackage ./nixpkgs-build/jmcomic.nix {};
          zsh-url-highlighter = pkgs.callPackage ./nixpkgs-build/zsh-url-highlighter.nix {};
          sddm-eucalyptus-drop = pkgs.callPackage ./nixpkgs-build/sddm-eucalyptus-drop.nix {};
          wechat-web-devtools-linux = pkgs.callPackage ./nixpkgs-build/wechat-web-devtools-linux.nix {};
          mikusays = pkgs.callPackage ./nixpkgs-build/mikusays.nix {};
          waybar-vd = pkgs.callPackage ./nixpkgs-build/waybar-vd.nix {};
          image-cut = input: pkgs.callPackage ./nixpkgs-build/image-cut.nix input;
          fortune-mod-zh = pkgs.callPackage ./nixpkgs-build/fortune-mod-zh.nix {};
          hyprlandPlugins =
            pkgs.hyprlandPlugins
            // {
              virtual-desktops = inputs.hyprland-virtual-desktops.packages.${system}.virtual-desktops;
              hypr-dynamic-cursors = inputs.hypr-dynamic-cursors.packages.${system}.hypr-dynamic-cursors.overrideAttrs (old: {
                # 依赖 wlroots
                nativeBuildInputs = pkgs.hyprland.nativeBuildInputs ++ (with pkgs; [hyprland gcc14]);
              });
            };
          intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
          waylrc = inputs.waylrc.packages.${system}.waylrc;
          # intel-graphics-compiler = master.intel-graphics-compiler;
          # libvdpau-va-gl = master.libvdpau-va-gl;
          # pkgsi686Linux = pkgs.pkgsi686Linux // {libvdpau-va-gl = master.pkgsi686Linux.libvdpau-va-gl;};
          # lutris = stable.lutris;
          qq = master.qq;
          feishu = master.feishu.override {
            commandLineArgs = ''
              "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
            '';
          };
          wemeet = master.wemeet;
          wechat = master.wechat;
          jellyfin-media-player = stable.jellyfin-media-player;
        }
      )
    ];
  };
}
