{ pkgs, ... }:

{
  home.file = {
    "ags/ags-launcher".source = "${pkgs.illogical-impulse.ags-launcher}";
  };
  xdg.dataFile = {
    "icons/Zafiro-Icons-Dark" = {
      source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Dark";
      force = true;
    };
    "icons/Zafiro-Icons-Light" = {
      source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Light";
      force = true;
    };
    "icons/MoreWaita" = {
      source = "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita";
    };
    "icons/OneUI" = {
      source = "${pkgs.illogical-impulse.oneui4-icons}/share/icons/OneUI";
    };
    "icons/OneUI-dark" = {
      source = "${pkgs.illogical-impulse.oneui4-icons}/share/icons/OneUI-dark";
    };
    "icons/OneUI-light" = {
      source = "${pkgs.illogical-impulse.oneui4-icons}/share/icons/OneUI-light";
    };
  };
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
  };
}
