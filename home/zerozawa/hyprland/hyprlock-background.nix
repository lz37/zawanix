{ pkgs, ... }:
let
  hyprlock-background = pkgs.writeShellScriptBin "hyprlock-background" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.coreutils}/bin:${pkgs.swww}/bin:${pkgs.gawk}/bin:${pkgs.hyprlock}/bin:$PATH

    # Find current background image path
    image_path=$(swww query | awk -F 'image: ' '{print $2}')

    if [ -f "$image_path" ]; then
      rm -f /tmp/hyprlock-background.jpg
      ${pkgs.imagemagick}/bin/convert "$image_path" /tmp/hyprlock-background.jpg
    fi
    wait && hyprlock
  '';
in
hyprlock-background
