{...}: {
  # The I226-V (0000:06:00.0) hangs on ASPM L1 and the igc driver detaches it
  # ("PCIe link lost, device now detached") while carrier still reads 1.
  # Disable ASPM for this device only, not the whole platform.
  boot.kernelParams = ["pcie_aspm.policy=performance"];
  systemd.services.disable-igc-aspm = {
    description = "Disable PCIe ASPM for the I226-V NIC";
    wantedBy = ["multi-user.target"];
    after = ["sysinit.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      dev=/sys/bus/pci/devices/0000:06:00.0
      [ -e "$dev/link/l1_aspm" ] || exit 0
      echo 0 > "$dev/link/l1_aspm" 2>/dev/null || true
      echo 0 > "$dev/link/l0s_aspm" 2>/dev/null || true
    '';
  };

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
