{
  inputs,
  pkgs,
  isNvidiaGPU,
  lib,
  ...
}@others:

let
  system-hyprland-settings = import ../../../system/hyprland.nix (
    {
      inherit
        inputs
        pkgs
        isNvidiaGPU
        lib
        ;
    }
    // others
  );
in
{
  wayland.windowManager.hyprland = {
    inherit (system-hyprland-settings.programs.hyprland) enable package portalPackage;
    xwayland.enable = true;
    settings = {
      env =
        (lib.optionals isNvidiaGPU [
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ])
        ++ [
          "NIXOS_OZONE_WL,1"
        ];
    };
  };
}
