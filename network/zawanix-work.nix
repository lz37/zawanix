{
  config,
  lib,
  ...
}: {
  networking = {
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = lib.mkForce false;
    nameservers = ["192.168.233.1"];
    timeServers = ["192.168.233.1"];
    wireless = {
      enable = true;
      interfaces = ["wlo1"];
      userControlled = false;
      networks.${config.zerozawa.network.wireless.ssid} = {
        psk = config.zerozawa.network.wireless.psk;
      };
    };
    interfaces = {
      # WiFi backup: higher metric (20 > 10) so enp1s0 is preferred when plugged.
      # When enp1s0 link drops → route withdrawn → traffic flows via wlo1 automatically.
      wlo1 = {
        useDHCP = false;
        ipv4 = {
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.233.1";
              options.metric = "20";
            }
          ];
          addresses = [
            {
              address = "192.168.233.223";
              prefixLength = 24;
            }
          ];
        };
      };
      enp1s0 = {
        useDHCP = false;
        wakeOnLan = {
          enable = true;
          policy = [
            "magic"
          ];
        };
        ipv4 = {
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.233.1";
              options.metric = "10";
            }
          ];
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
