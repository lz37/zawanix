{ pkgs, lib, ... }:
{
  hyprlock-background = pkgs.writeShellScriptBin "hyprlock-background" ''
    #!${lib.getExe pkgs.bash}

    # Find current background image path
    image_path=$(${lib.getExe pkgs.swww} query | awk -F 'image: ' '{print $2}')

    if [ -f "$image_path" ]; then
      rm -f /tmp/hyprlock-background.jpg
      ${lib.getExe' pkgs.imagemagick "convert"} "$image_path" /tmp/hyprlock-background.jpg
    fi
    wait && ${lib.getExe pkgs.hyprlock}
  '';
}
