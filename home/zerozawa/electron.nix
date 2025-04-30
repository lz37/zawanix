{ ... }:
{
  xdg.configFile = {
    "winapps/electron-flags.conf" = {
      text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
      force = true;
    };
  };
}
