{ ... }:
{
  xdg.configFile = {
    "winapps/winapps.conf" = {
      source = ./winapps.conf;
      force = true;
    };
    "winapps/compose.yaml" = {
      source = ./compose.yaml;
      force = true;
    };
  };
}
