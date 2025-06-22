{ pkgs, ... }:
let
  cursor = {
    theme = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
  };
in
{
  # Cursor
  home.sessionVariables = {
    XCURSOR_THEME = cursor.theme;
    XCURSOR_SIZE = 24;
  };

  home.pointerCursor = {
    package = cursor.package;
    name = cursor.theme;
    size = 24;
    gtk.enable = true;
  };

  xdg.dataFile."icons/MoreWaita" = {
    source = "${pkgs.morewaita-icon-theme}/share/icons";
  };
}
