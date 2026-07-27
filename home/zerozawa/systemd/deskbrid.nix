{
  pkgs,
  lib,
  ...
}: {
  systemd.user.services.deskbrid = {
    Unit = {
      Description = "Deskbrid desktop automation daemon";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.nur.repos.zerozawa.deskbrid} daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
