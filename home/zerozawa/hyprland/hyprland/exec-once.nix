{
  lib,
  pkgs,
  ...
}: {
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
      # "killall -q swaync;sleep .5 && swaync"
      "pypr &"
      "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
      "${lib.getExe' pkgs.kdePackages.kwallet "kwalletd6"} &"
      "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator"
      # (lib.getExe pkgs.fcitx5)
      "dbus-update-activation-environment --systemd  WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    ];
  };
}
