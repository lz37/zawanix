{...}: {
  stylix.targets.cava = {
    enable = true;
    rainbow.enable = true;
  };
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bar_spacing = 1;
        bar_width = 2;
        frame_rate = 60;
      };
      color = {
        gradient = 1;
      };
    };
  };
}
