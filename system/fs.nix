{ ... }:

{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
      priority = 1;
    }
  ];
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "15%";
  };
}
