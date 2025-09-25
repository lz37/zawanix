{
  isNvidiaGPU,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./oci-containers.nix
      ./waydroid.nix
    ]
    ++ (lib.optionals isNvidiaGPU [./nvidia-container-toolkit.nix]);

  environment.systemPackages = with pkgs; [
    crun
  ];

  virtualisation = {
    containers.enable = true;
    # docker
    docker = {
      enable = true;
      daemon.settings = {
        builder.gc = {
          defaultKeepStorage = "20GB";
          enabled = true;
        };
      };
    };
    # podman
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;
      # Required for containers under podman-compose to be able to talk to each other.
      # defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
}
