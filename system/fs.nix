{config, ...}: {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = config.zerozawa.hardware.ram;
      priority = -2;
    }
  ];
  boot.tmp = {
    cleanOnBoot = true;
  };
  services = {
    envfs.enable = true;
    gvfs.enable = true;
  };
}
