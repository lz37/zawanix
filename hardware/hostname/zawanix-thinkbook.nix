{...}: {
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
}
