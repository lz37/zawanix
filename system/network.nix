{
  hostName,
  config,
  ...
}:

{
  networking = {
    inherit hostName;
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = false;
    defaultGateway = {
      address = config.zerozawa.servers.openwrt.address;
      interface = "br0";
    };
    nameservers = [ config.zerozawa.servers.openwrt.address ];
    timeServers = [ config.zerozawa.servers.openwrt.address ];
    bridges = {
      "br0" = {
        interfaces = [ config.zerozawa.nixos.network.wired-interface ];
      };
    };
    interfaces = {
      "${config.zerozawa.nixos.network.wired-interface}" = {
        useDHCP = false;
      };
      br0 = {
        ipv4 = {
          addresses = [
            {
              address = config.zerozawa.nixos.network.static-address;
              prefixLength = 24;
            }
          ];
        };
      };
    };
  };
}
