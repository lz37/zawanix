{
  config,
  lib,
  pkgs,
  isNvidiaGPU,
  ...
}: let
  bg-kitty-conf = pkgs.writeText "bg-kitty-conf" ''
    font_family JetBrainsMono Nerd Font Mono
    background_opacity 0.0
    font_size 4.0
    include ${config.xdg.configHome}/kitty/dank-theme.conf
    scrollbar never
  '';
in {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      ''${lib.getExe pkgs.bash} -c "wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store &"'' # Saves text
      ''${lib.getExe pkgs.bash} -c "wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store &"'' # Saves images
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      # "systemctl --user start hyprpolkitagent"

      "killall -q swww;sleep .5 && swww-daemon"
      "systemctl --user start plasma-polkit-agent.service"
      # "killall -q waybar;sleep .5 && waybar"
      # "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &"
      # "systemctl --user start hyprpolkitagent.service"
      # 启动 DMS 并设置环境变量修复 NVIDIA EGL 崩溃
      ''QS_DISABLE_DMABUF=1 QT_QPA_PLATFORM=wayland ${
          if isNvidiaGPU
          then "DRI_PRIME=0 "
          else ""
        }dms run &''
      # "killall -q swaync;sleep .5 && swaync"
      "pypr &"
      "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
      "${lib.getExe' pkgs.kdePackages.kwallet "kwalletd6"} &"
      "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator"
      # (lib.getExe pkgs.fcitx5)
      "dbus-update-activation-environment --systemd  WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ''sleep 15 && ${lib.getExe' pkgs.kitty "kitten"} panel --edge=background -c ${bg-kitty-conf} "${lib.getExe pkgs.cava}" &''
    ];
  };
}
