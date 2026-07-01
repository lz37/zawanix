{config, ...}: {
  services.zerotierone = {
    enable = config.zerozawa.away-from-home;
    joinNetworks = [config.zerozawa.zerotier.id];
  };
}
