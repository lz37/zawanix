{
  ...
}:

{
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      socketActivation = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
      wireplumber = {
        enable = true;
        extraConfig = {
          "wh-1000xm3-ldac-hq" = {
            "monitor.bluez.rules" = [
              {
                matches = [
                  {
                    # `pactl list sinks` 查看
                    "device.name" = "~bluez_card.*";
                    "media.name" = "FIIO UTWS5";
                  }
                ];
                actions = {
                  update-props = {
                    # Set quality to high quality instead of the default of auto
                    "bluez5.a2dp.ldac.quality" = "hq";
                  };
                };
              }
            ];
          };
        };
      };
    };
  };
}
