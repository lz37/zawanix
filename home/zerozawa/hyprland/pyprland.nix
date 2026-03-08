{pkgs, ...}: {
  home.packages = with pkgs; [pyprland];
  xdg.configFile."pypr/config.toml".source = (pkgs.formats.toml {}).generate "pyprland.toml" {
    pyprland = {
      plugins = ["scratchpads"];
    };
    scratchpads.term = {
      animation = "fromTop";
      command = "kitty --class kitty-dropterm";
      position = "15% 15%";
      # unfocus = "hide";
      class = "kitty-dropterm";
      size = "70% 70%";
    };
  };
}
