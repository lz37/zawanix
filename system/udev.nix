{
  config,
  lib,
  ...
}: let
  devices = config.zerozawa.hardware.drm.devices;
  rules =
    builtins.concatMap (
      device:
        map (
          symlinkName: ''SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="${device.pciBusId}", SYMLINK+="dri/${symlinkName}"''
        )
        device.symlinkNames
    )
    devices;
in {
  assertions = [
    {
      assertion = builtins.all (device: device.symlinkNames != []) devices;
      message = "zerozawa.hardware.drm.devices must not contain empty symlinkNames";
    }
  ];

  services.udev.extraRules = lib.concatStringsSep "\n" rules;
}
