{
  pkgs,
  ...
}:

{
  environment.systemPackages =
    (with pkgs.kdePackages; [
      kdecoration
      isoimagewriter
      applet-window-buttons6
      kate
      qtwebsockets
      wallpaper-engine-plugin
      qtmultimedia
      koi
      partitionmanager
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
      vscode-runner
      krunner-translator
      application-title-bar
    ]);
}
