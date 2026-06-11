{config, ...}: {
  services.zerotierone = {
    enable = config.zerozawa.hardware.isLaptop;
    joinNetworks = [config.zerozawa.zerotier.id];
  };
}
