{config, ...}: let
  hostName = config.networking.hostName;
  dhcpByHost = {
    zawanix-work = false;
    zawanix-glap = true;
    zawanix-fubuki = false;
  };
in {
  hardware.facter = {
    enable = true;
    reportPath = ./. + "/${hostName}.json";
    detected = {
      dhcp.enable =
        if builtins.hasAttr hostName dhcpByHost
        then dhcpByHost.${hostName}
        else false;
    };
  };
}
