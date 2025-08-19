{ pkgs, ... }:
{
  xdg.configFile."ags" = {
    source = pkgs.illogical-impulse.ags;
    recursive = true;
  };
}
