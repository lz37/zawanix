{ pkgs, ... }:
let
  cursor-theme = "Bibata-Modern-Classic";
  cursor-package = pkgs.bibata-cursors;
in
{
  home = {
    pointerCursor = {
      package = cursor-package;
      name = cursor-theme;
      size = 24;
      gtk.enable = true;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
  gtk = {
    enable = true;
    font.name = "Rubik";
    theme.name = "adw-gtk3-dark";
    cursorTheme = {
      name = cursor-theme;
      package = cursor-package;
    };
    iconTheme.name = "MoreWaita";
    gtk3.extraCss = ''
      headerbar, .titlebar,
      .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
        border-radius: 0;
      }
    '';
  };
}
