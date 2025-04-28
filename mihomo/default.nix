{ config, pkgs, ... }:
{
  services.mihomo = {
    package = pkgs.mihomo;
    tunMode = false;
    enable = true;
    webui = pkgs.yacd;
    mihomoCfg = config.zerozawa.path.clashCfg;
  };
}
