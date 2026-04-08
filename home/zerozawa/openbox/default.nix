{...}: {
  imports = [
    ./autostart.nix
    ./environment.nix
  ];
  xdg.configFile."openbox/rc.xml".source = ./rc.xml;
}
