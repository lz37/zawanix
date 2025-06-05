{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.file = {
    ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/git/config";
    ".cherrystudio/bin/bun".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.bun}/bin/bun";
    ".cherrystudio/bin/uv".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.uv}/bin/uv";
    ".cherrystudio/bin/uvx".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.uv}/bin/uvx";
  };
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = lib.mkForce "${config.home.homeDirectory}/Desktop";
      documents = lib.mkForce "${config.home.homeDirectory}/Documents";
      download = lib.mkForce config.zerozawa.path.downloads;
      music = lib.mkForce "${config.home.homeDirectory}/Music";
      pictures = lib.mkForce "${config.home.homeDirectory}/Pictures";
      publicShare = lib.mkForce config.zerozawa.path.public;
      templates = lib.mkForce "${config.home.homeDirectory}/Templates";
      videos = lib.mkForce "${config.home.homeDirectory}/Videos";
    };
  };
}
