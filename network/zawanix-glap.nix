{...}: {
  networking = {
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = true;
  };
}
