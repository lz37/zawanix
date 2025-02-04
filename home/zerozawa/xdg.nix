{ config, ... }:
{
  home.file = {
    ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/git/config";
  };
}
