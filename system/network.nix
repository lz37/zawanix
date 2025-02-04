{
  config,
  ...
}:

let
  hostName = "zawanix";
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
