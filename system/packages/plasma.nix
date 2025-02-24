{
  pkgs,
  pkgs-stable,
  ...
}:

{
  environment.systemPackages =
    (with pkgs.kdePackages; [
      yakuake
      kdecoration
      isoimagewriter
      # applet-window-buttons6
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
    ]);
}
