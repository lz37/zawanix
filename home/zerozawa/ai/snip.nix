{pkgs, ...}: {
  xdg.configFile = {
    "snip/config.toml".source = pkgs.writers.writeTOML "config.toml" {
      display = {
        color = true;
        emoji = true;
        quiet_no_filter = true; # suppress "no filter" stderr messages
      };
    };
  };
}
