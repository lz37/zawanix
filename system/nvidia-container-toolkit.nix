{ ... }:

{
  hardware.nvidia-container-toolkit = {
    enable = true;
  };
  virtualisation = {
    docker = {
      daemon.settings = {
        features.cdi = true;
        default-runtime = "nvidia";
      };
    };
  };
}
