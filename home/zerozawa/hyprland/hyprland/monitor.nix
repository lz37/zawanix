{ lib, hostName, ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        ", preferred, auto, 1"
      ];
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
            output = "desc:California Institute of Technology 0x1509";
            mode = "2560x1440@165";
            position = "0x0";
            cm = "edid";
            scale = 1;
            bitdepth = 12;
          }
          {
            output = "desc:SAC G52 0000000000000";
            mode = "2560x1440@180";
            position = "2560x0";
            scale = 1;
            cm = "hdr";
            bitdepth = 8;
            vrr = true;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 400;
          }
        ])
      );
    };
  };
}
