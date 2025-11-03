{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    shellAliases = {
      find = lib.getExe pkgs.fd;
      wakatime = lib.getExe pkgs.wakatime-cli;
    };
  };
}
