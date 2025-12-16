{...}: {
  services = {
    linyaps.enable = true;
    flatpak = {
      enable = true;
      packages = [
        # "com.tencent.wemeet"
        "com.github.tchx84.Flatseal"
        "io.github.giantpinkrobots.flatsweep"
      ];
      update = {
        onActivation = false;
        auto = {
          enable = true;
          onCalendar = "daily";
        };
      };
      uninstallUnused = true;
    };
  };
}
