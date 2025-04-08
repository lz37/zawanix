{
  pkgs,
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
        configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
            monitor.bluez.properties = {
              bluez5.roles = [ hsp_hs hsp_ag hfp_hf hfp_ag a2dp_sink a2dp_source bap_sink bap_source]
              bluez5.codecs = [ sbc sbc_xq aac ldac aptx]
              bluez5.enable-msbc = true
              bluez5.enable-sbc-xq = true
              bluez5.enable-hw-volume = true
              bluez5.hfphsp-backend = "native"
            }
          '')
        ];
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
