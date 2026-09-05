{
  lib,
  config,
  ...
}: let
  router = "192.168.2.1";
  wiredAddress = "192.168.2.123";
  wifiAddress = "192.168.2.124";
in {
  networking = {
    timeServers = [router];
    enableIPv6 = true;
    firewall.enable = false;
    useDHCP = lib.mkForce false;

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      settings = {
        # Wait for the declarative profile instead of creating a DHCP profile.
        main.no-auto-default = "eno1";
        device-eno1 = {
          match-device = "interface-name:eno1";
          ignore-carrier = false;
          keep-configuration = false;
        };
        device-wlp7s0 = {
          match-device = "interface-name:wlp7s0";
          keep-configuration = false;
        };
        # Demote an unusable default route even if the NIC still reports carrier.
        connectivity = {
          enabled = true;
          uri = "http://connectivitycheck.platform.hicloud.com/generate_204";
          response = "";
          interval = 15;
          timeout = 5;
        };
      };

      ensureProfiles.profiles = {
        fubuki-wired = {
          connection = {
            id = "fubuki-wired";
            type = "ethernet";
            interface-name = "eno1";
            autoconnect = true;
            autoconnect-retries = 0;
          };
          ethernet.wake-on-lan = 64; # magic
          ipv4 = {
            method = "manual";
            address1 = "${wiredAddress}/24";
            gateway = router;
            dns = "${router};";
            # Equal DNS priority and routing domains keep both per-link paths usable.
            dns-priority = 100;
            dns-search = "~.;";
            route-metric = 10;
            route-table = 254;
            # Source-pinned replies stay symmetric; NM owns their lifecycle.
            route1 = "192.168.2.0/24";
            route1_options = "table=10";
            route2 = "0.0.0.0/0,${router}";
            route2_options = "table=10";
            routing-rule1 = "priority 100 from ${wiredAddress}/32 table 10";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
            ignore-auto-dns = true;
            route-metric = 10;
          };
        };

        # Stay associated while Ethernet is healthy so failover needs no Wi-Fi login.
        fubuki-wifi = {
          connection = {
            id = "fubuki-wifi";
            type = "wifi";
            interface-name = "wlp7s0";
            autoconnect = true;
            autoconnect-retries = 0;
          };
          wifi = {
            mode = "infrastructure";
            cloned-mac-address = "permanent";
            # ensureProfiles runs envsubst; preserve literal dollar signs.
            ssid = lib.replaceStrings ["$"] ["$$"] config.zerozawa.network.wireless.ssid;
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = lib.replaceStrings ["$"] ["$$"] config.zerozawa.network.wireless.psk;
          };
          ipv4 = {
            method = "manual";
            address1 = "${wifiAddress}/24";
            gateway = router;
            dns = "${router};";
            dns-priority = 100;
            dns-search = "~.;";
            route-metric = 20;
            route-table = 254;
            route1 = "192.168.2.0/24";
            route1_options = "table=20";
            route2 = "0.0.0.0/0,${router}";
            route2_options = "table=20";
            routing-rule1 = "priority 200 from ${wifiAddress}/32 table 20";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
            ignore-auto-dns = true;
            route-metric = 20;
          };
        };
      };
    };
  };
  # Both interfaces share a subnet; do not answer ARP for the other NIC's IP.
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_announce" = 2;
  };

  services = {
    # Bind DNS queries to each link rather than the preferred connected /24 route.
    resolved.enable = true;
    # Keep the static-address server enabled after leaving scripted networking.
    rustdesk-server = {
      enable = true;
      openFirewall = true;
      signal.relayHosts = [
        "localhost"
        wiredAddress
        wifiAddress
      ];
    };
  };
}
