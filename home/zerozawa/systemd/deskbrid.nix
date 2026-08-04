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
      Environment = [
        "AT_SPI_BUS_ADDRESS=unix:path=%t/at-spi/bus_0"
        # "LC_ALL=C" # pactl output is locale-localized; deskbrid parses English
      ];
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
