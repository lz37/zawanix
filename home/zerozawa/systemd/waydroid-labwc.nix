{
  pkgs,
  lib,
  ...
}: {
  systemd.user.services.waydroid-labwc = {
    Unit = {
      Description = "Waydroid in labwc";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.labwc} -s \"waydroid show-full-ui\"";
      Restart = "on-failure";
      RestartSec = 3;
    };
    # No [Install] — manual start only
  };
}
