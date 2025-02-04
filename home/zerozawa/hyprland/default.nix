{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "monitor" = ",preferred,auto,auto";
    "$terminal" = "${pkgs.kitty}/bin/kitty";
    "$fileManager" = "${pkgs.dolphin}/bin/dolphin";
    "$menu" = "${pkgs.wofi}/bin/wofi --show drun";
    "env" = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];
  };
}
