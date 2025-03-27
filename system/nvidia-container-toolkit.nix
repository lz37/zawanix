{ ... }:

{
  hardware.nvidia-container-toolkit = {
    enable = true;
  };
  virtualisation = {
    podman.enableNvidia = true;
    docker = {
      enableNvidia = true;
      virtualisation.docker.daemon.settings.features.cdi = true;
    };
  };
}
