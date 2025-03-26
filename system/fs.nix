{ ram, ... }:

{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = ram;
      priority = 1;
    }
  ];
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "15%";
  };
}
