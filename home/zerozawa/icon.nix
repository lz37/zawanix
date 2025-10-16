{
  pkgs,
  lib,
  ...
}: let
  icons = with pkgs; [
    (lib.hiPrio zafiro-icons)
    morewaita-icon-theme
    colloid-icon-theme
    papirus-icon-theme
  ];
  icons-matome = pkgs.buildEnv {
    name = "icons-matome";
    paths = icons;
  };
  icons-path = "${icons-matome}/share/icons";
in {
  home = {
    packages = icons;
    file.".icons".source = icons-path;
  };
  xdg.dataFile."icons".source = icons-path;
}
