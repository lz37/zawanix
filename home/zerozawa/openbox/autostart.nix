{
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."openbox/autostart" = {
    executable = true;
    text = ''
      #!/bin/bash
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
        DISPLAY \
        XAUTHORITY \
        DBUS_SESSION_BUS_ADDRESS \
        XDG_CURRENT_DESKTOP \
        DESKTOP_SESSION \
        XDG_SESSION_TYPE

      ${pkgs.systemd}/bin/systemctl --user import-environment \
        DISPLAY \
        XAUTHORITY \
        DBUS_SESSION_BUS_ADDRESS \
        XDG_CURRENT_DESKTOP \
        DESKTOP_SESSION \
        XDG_SESSION_TYPE

      ${pkgs.systemd}/bin/systemctl --user reset-failed plasma-polkit-agent.service
      ${pkgs.systemd}/bin/systemctl --user restart plasma-polkit-agent.service &
      ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init
      ${lib.getExe' pkgs.kdePackages.kwallet "kwalletd6"} &
    '';
  };
}
