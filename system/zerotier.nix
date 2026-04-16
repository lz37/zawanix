{config, ...}: {
  services.zerotierone = {
    enable = config.networking.hostName == "zawanix-glap";
    joinNetworks = [config.zerozawa.zerotier.id];
  };
}
