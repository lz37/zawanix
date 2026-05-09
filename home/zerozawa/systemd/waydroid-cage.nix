{pkgs, ...}: {
  systemd.user.services.waydroid-cage = {
    Unit = {
      Description = "Waydroid in Cage (iGPU)";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cage}/bin/cage -- waydroid show-full-ui";
      Environment = [
        "WLR_DRM_DEVICES=/dev/dri/igpu"
        "WAYLAND_DISPLAY=wayland-1"
      ];
      Restart = "on-failure";
      RestartSec = 3;
    };
    # No [Install] — manual start only
  };
}
