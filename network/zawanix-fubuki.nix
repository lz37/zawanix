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
            # Default in main table (metric 10 → primary)
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options.metric = "10";
            }
            # Same default in table 10 for source-based routing
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options = {
                metric = "10";
                table = "10";
              };
            }
            # Subnet route in table 10 (table 10 needs to know local subnet)
            {
              address = "192.168.2.0";
              prefixLength = 24;
              options.table = "10";
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
            # Default in main table (metric 20 → backup)
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options.metric = "20";
            }
            # Same default in table 20 for source-based routing
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.2.1";
              options = {
                metric = "20";
                table = "20";
              };
            }
            # Subnet route in table 20
            {
              address = "192.168.2.0";
              prefixLength = 24;
              options.table = "20";
            }
          ];
        };
      };
    };
  };

  # === DUAL-NIC SAME-SUBNET FIXES ===
  # Both eno1 and wlp7s0 on 192.168.2.0/24 cause:
  # 1. ARP flux — router sees two MACs for the same IP, packets get lost
  # 2. Asymmetric routing — outbound and reply paths differ
  # Fix: ARP hardening + policy routing for symmetric paths

  boot.kernel.sysctl = {
    # ARP: only answer queries for addresses assigned to the receiving interface.
    # Prevents router ARP cache from flip-flopping between eno1 and wlp7s0 MACs.
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_announce" = 2;
  };

  # Policy routing rules so return traffic uses the same interface as outbound.
  # Runs before network.target, but the kernel accepts rules regardless of
  # whether the source IP exists yet — they start matching once addresses are up.
  networking.localCommands = ''
    ip rule add from 192.168.2.123 table 10 priority 100 2>/dev/null || true
    ip rule add from 192.168.2.124 table 20 priority 200 2>/dev/null || true
  '';
}
