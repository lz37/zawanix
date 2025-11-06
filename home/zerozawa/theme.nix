{
  pkgs,
  lib,
  ...
}: let
  icons-matome = pkgs.buildEnv {
    name = "icons-matome";
    paths = with pkgs; [
      (lib.hiPrio zafiro-icons)
      morewaita-icon-theme
      colloid-icon-theme
      papirus-icon-theme
      kdePackages.breeze-icons
    ];
  };
  icons-path = "${icons-matome}/share/icons";
  themes-matome = pkgs.buildEnv {
    name = "themes-matome";
    paths = with pkgs; [
      colloid-gtk-theme
      kdePackages.breeze-gtk
    ];
  };
  themes-path = "${themes-matome}/share/themes";
in {
  home.file = {
    ".icons".source = icons-path;
    ".themes".source = themes-path;
  };
  xdg = {
    dataFile = {
      "icons".source = icons-path;
      "themes".source = themes-path;
    };
  };
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = icons-matome;
    };
    theme = {
      name = "Breeze-Dark";
      package = themes-matome;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
}
