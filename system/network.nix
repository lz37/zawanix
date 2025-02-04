{
  hostName,
  ...
}:

{
  networking = {
    inherit hostName;
    enableIPv6 = true;
    firewall.enable = false;
    networkmanager.enable = true;
  };
}
