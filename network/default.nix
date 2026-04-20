{hostName, ...}: {
  imports = [
    (./. + "/${hostName}.nix")
  ];
  networking.hostName = hostName;
}
