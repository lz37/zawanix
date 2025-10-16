{
  pkgs,
  config,
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
    ];
  };
  icons-path = "${icons-matome}/share/icons";
  themes-matome = pkgs.buildEnv {
    name = "themes-matome";
    paths = with pkgs; [
      colloid-gtk-theme
    ];
  };
  themes-path = "${themes-matome}/share/themes";
  gtk-theme-name = "Colloid-Dark";
  common-gtk-config = {
    gtk-application-prefer-dark-theme = true;
    gtk-enable-animations = true;
    gtk-cursor-blink = true;
    gtk-cursor-blink-time = 1000;
    gtk-cursor-theme-name = "breeze_cursors";
    gtk-cursor-theme-size = 24;
    gtk-decoration-layout = ":";
    gtk-font-name = "Noto Sans,  9";
    gtk-modules = "appmenu-gtk-module:colorreload-gtk-module";
    gtk-primary-button-warps-slider = true;
    gtk-sound-theme-name = "ocean";
    inherit gtk-theme-name;
  };
in {
  home.file = {
    ".icons".source = icons-path;
    ".themes".source = themes-path;
  };
  xdg = {
    configFile."gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/gtk-3.0/dank-colors.css";
    dataFile = {
      "icons".source = icons-path;
      "themes".source = themes-path;
    };
  };
  gtk = {
    enable = true;
    gtk3 = {
      extraConfig = common-gtk-config;
    };
    gtk4 = {
      extraCss = ''
        @import url("file://${config.xdg.configHome}/gtk-4.0/dank-colors.css");
        @import url("file://${themes-path}/${gtk-theme-name}/gtk-4.0/gtk.css");
      '';
      extraConfig = common-gtk-config;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = icons-matome;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
}
