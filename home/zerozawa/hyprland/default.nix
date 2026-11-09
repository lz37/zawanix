{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}:
let
  optLua = import ./option.nix { inherit config osConfig lib; };
  repo = "${config.zerozawa.path.cfgRoot}/home/zerozawa/hyprland/lua";
in
{
  imports = [
    ./hypridle.nix
    ./pyprland.nix
  ];

  home.packages = with pkgs; [
    awww
    swappy
    ydotool
    hyprpolkitagent
    hyprland-guiutils
    hyprpicker
    swayimg
    hyprcursor
    playerctl
    brightnessctl
    kdePackages.qt6ct
    wev
  ];

  home.activation.deployHyprConfig = lib.hm.dag.entryBefore [ "writeBoundary" ] /* bash */ ''
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

        # 3. Symlink hyprsplit source (flake = false, just init.lua)
        ${pkgs.coreutils}/bin/mkdir -p ${repo}
        ${pkgs.coreutils}/bin/ln -sfn ${inputs.hyprsplit} ${repo}/hyprsplit
  '';
}
