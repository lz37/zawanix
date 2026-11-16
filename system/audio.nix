{ pkgs, ... }: {
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
      # jack.enable 已弃用：它把 pipewire 的 libjack 塞进全局
      # sessionVariables.LD_LIBRARY_PATH，污染所有进程。JACK 客户端一律用
      # `pw-jack <client>` 启动（pw-jack 只在自身进程里设 LD_LIBRARY_PATH）。
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

  # 提供 `pw-jack`：JACK 客户端按需用它启动，替代原先的全局 LD_LIBRARY_PATH。
  environment.systemPackages = [ pkgs.pipewire.jack ];
}
