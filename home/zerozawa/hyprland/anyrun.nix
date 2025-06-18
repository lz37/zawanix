# https://github.com/bigsaltyfishes/end-4-dots/blob/main/modules/anyrun.nix
{ pkgs, ... }:
{
  programs.anyrun = {
    enable = true;
    package = pkgs.anyrun-git-pkgs.anyrun;
    config = {
      plugins = with pkgs.anyrun-git-pkgs; [
        applications
        randr
        rink
        shell
        symbols
      ];
      x = {
        fraction = 0.500000;
      };
      y = {
        absolute = 15;
      };
      width = {
        fraction = 0.300000;
      };
      height = {
        absolute = 0;
      };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
    };
  };
}
