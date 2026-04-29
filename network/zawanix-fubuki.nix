{
  lib,
  config,
  ...
}: {
  # === NETWORKING LAYER ===
  networking = {
    nameservers = ["192.168.2.1"];
    timeServers = ["192.168.2.1"];
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = lib.mkForce false;

    wireless = {
      enable = true;
      interfaces = ["wlp7s0"];
      userControlled = false;
      networks.${config.zerozawa.network.wireless.ssid} = {
        psk = config.zerozawa.network.wireless.psk;
      };
    };

    interfaces = {
      eno1 = {
        useDHCP = false;
        wakeOnLan = {
          enable = true;
          policy = ["magic"];
        };
        ipv4 = {
          # Explicit default route instead of networking.defaultGateway
          # This avoids the /32 scope-link route that forces all gateway
          # traffic through eno1, which would cripple WiFi's RX path.
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options.metric = "10";
            }
          ];

          addresses = [
            {
              address = "192.168.2.123";
              prefixLength = 24;
            }
          ];
        };
      };
      # WiFi backup: separate IP, higher metric default route
      # When eno1 link drops → route withdrawn → traffic flows via wlp7s0
      wlp7s0 = {
        useDHCP = false;
        ipv4 = {
          addresses = [
            {
              address = "192.168.2.124";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options.metric = "20";
            }
          ];
        };
      };
    };
  };
}
