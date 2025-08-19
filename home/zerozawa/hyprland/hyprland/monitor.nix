{ lib, hostName, ... }:
let
in
{
  wayland.windowManager.hyprland = {
    settings = {
      monitorv2 = (
        lib.optionals (hostName == "zawanix-work") [
          {
            output = "HDMI-A-1";
            mode = "3840x2160@60";
            position = "0x0";
            scale = 2;
            cm = "hdr";
            bitdepth = 10;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 400;
          }
          {
            output = "DP-3";
            mode = "1920x1080@60";
            position = "1920x0";
            scale = 1;
          }
        ]
        ++ (lib.optionals (hostName == "zawanix-glap") [
          {
            output = "eDP-1";
            mode = "2560x1440@165";
            position = "0x0";
            scale = 1;
          }
          {
            output = "DP-1";
            mode = "2560x1440@180";
            position = "2560x0";
            scale = 1;
            cm = "hdr";
            # bitdepth = 10;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 400;
          }
        ])
      );
    };
  };
}
