{
  config,
  lib,
  ...
}:
lib.mkIf (config.networking.hostName == "zawanix-glap") {
  networking = {
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = true;
  };
}
