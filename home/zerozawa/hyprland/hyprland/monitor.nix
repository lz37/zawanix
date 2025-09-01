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
            output = "desc:Lectron Company Ltd LECOO M2732PL GG1FF276";
            mode = "3840x2160@60";
            position = "0x0";
            scale = 2;
            cm = "hdr";
            bitdepth = 10;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 400;
            vrr = true;
          }
          {
            output = "desc:Dell Inc. DELL P2314H HMJ1V66S787S";
            mode = "1920x1080@60";
            position = "1920x0";
            scale = 1;
            bitdepth = 8;
          }
        ]
        ++ (lib.optionals (hostName == "zawanix-glap") [
          {
            output = "desc:California Institute of Technology 0x1509";
            mode = "2560x1440@165";
            position = "0x0";
            cm = "edid";
            scale = 1;
            bitdepth = 10;
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
