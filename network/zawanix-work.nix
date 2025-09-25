{hostName, ...}: {
  networking = {
    inherit hostName;
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = false;
    defaultGateway = {
      address = "192.168.233.1";
      interface = "br0";
    };
    nameservers = ["192.168.233.1"];
    timeServers = ["192.168.233.1"];
    bridges = {
      "br0" = {
        interfaces = ["enp1s0"];
      };
    };
    interfaces = {
      enp1s0 = {
        useDHCP = false;
        wakeOnLan = {
          enable = true;
          policy = [
            "magic"
          ];
        };
      };
      br0 = {
        ipv4 = {
          addresses = [
            {
              address = "192.168.233.233";
              prefixLength = 24;
            }
          ];
        };
      };
    };
  };
}
