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
    networkmanager.enable = true;
  };
}
