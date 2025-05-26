{ ram, useTmpfs, ... }:

{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = ram;
      priority = 1;
    }
  ];
  boot.tmp = {
    inherit useTmpfs;
    cleanOnBoot = true;
  };
}
