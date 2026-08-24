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
      spectacle
      (pkgs.runCommand "expose-pam_kwallet_init" {} ''
        mkdir -p $out/bin
        ln -s ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init $out/bin/pam_kwallet_init
      '')
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
      vscode-runner
      application-title-bar
      nur.repos.xddxdd.lyrica-plasmoid
      valent
    ]);
}
