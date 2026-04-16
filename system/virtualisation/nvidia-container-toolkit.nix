{
  lib,
  config,
  ...
}:
lib.mkIf config.zerozawa.hardware.isNvidiaGPU {
  hardware.nvidia-container-toolkit = {
    enable = true;
  };
  virtualisation = {
    docker = {
      daemon.settings = {
        # --device=nvidia.com/gpu=all
        features.cdi = true;
      };
    };
  };
}
