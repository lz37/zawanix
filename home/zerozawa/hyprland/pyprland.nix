{pkgs, ...}: {
  home.packages = with pkgs; [pyprland];
  xdg.configFile."hypr/pyprland.toml".source = (pkgs.formats.toml {}).generate "pyprland.toml" {
    pyprland = {
      plugins = ["scratchpads"];
    };
    scratchpads.term = {
      animation = "fromTop";
      command = "kitty --class kitty-dropterm";
      # unfocus = "hide";
      class = "kitty-dropterm";
      size = "70% 70%";
      margin = "15%";
    };
  };
}
