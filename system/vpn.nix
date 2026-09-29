{
  config,
  lib,
  ...
}:
lib.mkIf config.zerozawa.away-from-home {
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [config.zerozawa.zerotier.id];
    };
    easytier = {
      enable = true;
      allowSystemForward = true;
      instances = {
        work.configServer = config.zerozawa.easytier.work.configServer;
      };
    };
  };
}
