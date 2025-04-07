{ ... }:
{
  xdg.configFile = {
    "winapps/winapps.conf" = {
      source = ./winapps.conf;
      force = true;
    };
  };
}
