{
  pkgs,
  ...
}:

{
  environment.systemPackages =
    (with pkgs.kdePackages; [
      yakuake
      kdecoration
      isoimagewriter
      applet-window-buttons6
      kate
      qtwebsockets
      wallpaper-engine-plugin
      qtmultimedia
      koi
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
    ]);
}
