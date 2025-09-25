{pkgs, ...}: {
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
      krdc
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
      vscode-runner
      application-title-bar
      nur.repos.xddxdd.lyrica-plasmoid
    ]);
}
