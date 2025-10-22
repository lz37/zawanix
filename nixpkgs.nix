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
          vscode-selected = master.vscode.override {useVSCodeRipgrep = true;};
          vscode-selected-extensionsCompatible = (
            (pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected)
          );
          teleport = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          image-cut = input: pkgs.callPackage ./nixpkgs-build/image-cut.nix input;
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
          nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
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
        }
      )
    ];
  };
}
