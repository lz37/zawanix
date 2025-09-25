{...}: {
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
