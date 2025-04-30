{ pkgs, hostName, ... }:

if hostName == "zawanix-glap" then
  {
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = "wlr";
        };
      };
      wlr = {
        enable = true;
        settings = {
          screencast = {
            output_name = "eDP-1";
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
            max_fps = 60;
          };
        };
      };
    };

  }
else
  { }
