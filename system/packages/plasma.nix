{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs.kdePackages; [
    yakuake
    kdecoration
    applet-window-buttons6
  ];
}
