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
        # https://github.com/TLATER/dotfiles/blob/a31d74856710936b398318062f0af6616d994eba/nixos-config/default.nix#L189
        extraConfig = {
          "50-bluez" = {
            "monitor.bluez.rules" = [
              {
                matches = [ { "device.name" = "~bluez_card.*"; } ];
                actions = {
                  update-props = {
                    "bluez5.a2dp.ldac.quality" = "hq";
                    "bluez5.auto-connect" = [
                      "a2dp_sink"
                      "a2dp_source"
                    ];
                    "bluez5.hw-volume" = [
                      "a2dp_sink"
                      "a2dp_source"
                    ];
                  };
                };
              }
            ];
            "monitor.bluez.properties" = {
              "bluez5.roles" = [
                "a2dp_sink"
                "a2dp_source"
                "bap_sink"
                "bap_source"
              ];
              "bluez5.codecs" = [
                "ldac"
                "aptx"
                "aptx_ll_duplex"
                "aptx_ll"
                "aptx_hd"
                "opus_05_pro"
                "opus_05_71"
                "opus_05_51"
                "opus_05"
                "opus_05_duplex"
                "aac"
                "sbc_xq"
              ];
              "bluez5.hfphsp-backend" = "none";
            };
          };
        };
      };
    };
  };
}
