{
  config,
  ...
}:

let
  router = config.zerozawa.servers.openwrt.ip;
  interface = "ens18";
  hostName = "nixserver";
  ip = config.zerozawa.servers.nixserver.ip;
  prefixLength = config.zerozawa.servers.nixserver.prefixLength;
in
{
  networking = {
    inherit hostName;
    firewall.enable = false;
    nameservers = [ router ];
    timeServers = [ router ];
    defaultGateway = {
      address = router;
      interface = interface;
    };
    interfaces = {
      ${interface} = {
        mtu = 9000;
        ipv4 = {
          addresses = [
            {
              address = ip;
              inherit prefixLength;
            }
          ];
        };
      };
    };
  };
}
