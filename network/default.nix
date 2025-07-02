{
  hostName,
  config,
  ...
}:

{
  imports = [
    (./. + "/${hostName}.nix")
  ];
  networking.extraHosts = config.zerozawa.network.hosts;
}
