{...}: {
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/4A52-0070";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/f9e2692c-725e-4562-979b-46dbbd62c508";
      fsType = "ext4";
    };
  };
  # PRIME bus IDs are auto-derived from facter in hardware/nvidia/gpu.nix.
}
