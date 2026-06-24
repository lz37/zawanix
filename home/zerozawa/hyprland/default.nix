{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}: let
  optLua = import ./option.nix {inherit config osConfig lib;};
  repo = "${config.zerozawa.path.cfgRoot}/home/zerozawa/hyprland/lua";
in {
  imports = [
    ./hypridle.nix
    ./pyprland.nix
  ];

  home.packages = with pkgs; [
    awww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils
    hyprpicker
    swayimg
    hyprcursor
    playerctl
    brightnessctl
    kdePackages.qt6ct
    wev
    ccal
  ];

  home.activation.deployHyprConfig = lib.hm.dag.entryBefore ["writeBoundary"] ''
        # 1. Symlink lua/ from repo (writable for DMS and lux)
        if [ ! -L "$HOME/.config/hypr" ] && [ -d "$HOME/.config/hypr" ]; then
          mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak.$(date +%s)"
        fi
        ${pkgs.coreutils}/bin/ln -sfn ${repo} "$HOME/.config/hypr"

        # 2. Write generated option.lua directly to repo (gitignored)
        ${pkgs.coreutils}/bin/mkdir -p ${repo}
        cat > ${repo}/option.lua << 'LUAEOF'
    ${optLua}
    LUAEOF

        # 3. Symlink pam_kwallet_init (libexec, not in PATH)
        ${pkgs.coreutils}/bin/mkdir -p ${repo}/bin
        ${pkgs.coreutils}/bin/ln -sfn ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init ${repo}/bin/pam_kwallet_init

        # 4. Symlink plugin .so files
        ${pkgs.coreutils}/bin/mkdir -p ${repo}/plugins
        ${pkgs.coreutils}/bin/ln -sfn ${pkgs.hyprlandPlugins.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so ${repo}/plugins/hypr-dynamic-cursors.so
        ${pkgs.coreutils}/bin/ln -sfn ${pkgs.hyprlandPlugins.hyprfocus}/lib/libhyprfocus.so ${repo}/plugins/hyprfocus.so

        # 5. Symlink hyprsplit source (flake = false, just init.lua)
        ${pkgs.coreutils}/bin/mkdir -p ${repo}
        ${pkgs.coreutils}/bin/ln -sfn ${inputs.hyprsplit} ${repo}/hyprsplit
  '';
}
