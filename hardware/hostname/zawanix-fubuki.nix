{
  config,
  lib,
  ...
}:
lib.mkIf (config.networking.hostName == "zawanix-fubuki") {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/eaa43e13-12b3-47f2-ad61-efaacc0b1b70";
      fsType = "ext4";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2915-349A";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
}
