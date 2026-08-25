{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home.file = {
    ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/git/config";
    ".cherrystudio/bin/bun".source = config.lib.file.mkOutOfStoreSymlink (lib.getExe inputs.nix-bun.packages.${pkgs.stdenv.system}.bun);
    ".cherrystudio/bin/uv".source = config.lib.file.mkOutOfStoreSymlink (lib.getExe pkgs.uv);
    ".cherrystudio/bin/uvx".source = config.lib.file.mkOutOfStoreSymlink (lib.getExe pkgs.uv);
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
    desktopEntries.waydroid-labwc = {
      name = "Waydroid (labwc)";
      comment = "Waydroid fullscreen in labwc";
      exec = "${lib.getExe pkgs.labwc} -s \"${lib.getExe pkgs.waydroid} show-full-ui\"";
      icon = "waydroid";
      type = "Application";
      categories = ["System"];
    };
  };
}
