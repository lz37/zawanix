{
  inputs,
  lib,
  rootPath,
  ...
}: let
  oculinkFacter = rootPath + "/hardware/facter/zawanix-thinkbook.oculink.json";
in {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c681d414-0087-40c2-8c1b-9e5c71eac1c2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6B80-4476";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  # OCuLink eGPU specialization: Intel iGPU + NVIDIA dGPU via OCuLink
  # Select "oculink" from systemd-boot menu when eGPU is connected.
  specialisation.oculink.configuration = {
    zerozawa.hardware.isOculink = lib.mkForce true;
    # Switch to the oculink facter report which includes both GPUs.
    hardware.facter.reportPath = lib.mkForce oculinkFacter;
  };
}
