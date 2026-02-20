{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    shellAliases = {
      wakatime = lib.getExe pkgs.wakatime-cli;
    };
  };
}
