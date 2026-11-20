{ config, ... }: {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      # 5/4 RAM：留出休眠镜像（≈RAM/2 上限）之外，还能容忍 zswap 溢出占用
      size = config.zerozawa.hardware.ram * 5 / 4;
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
