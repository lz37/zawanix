{
  hostName,
  config,
  ...
}: {
  services.zerotierone = {
    enable = hostName == "zawanix-glap";
    joinNetworks = [config.zerozawa.zerotier.id];
  };
}
