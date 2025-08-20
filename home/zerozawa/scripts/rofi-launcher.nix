{ pkgs }:
pkgs.writeShellScriptBin "rofi-launcher" ''
  # check if rofi is already running
  if pidof rofi > /dev/null; then
    pkill rofi
  fi
  ${pkgs.rofi-wayland}/bin/rofi -show drun
''
