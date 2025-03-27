{
  pkgs,
  isNvidiaGPU,
  lib,
  ...
}:

{

  imports = lib.optionals isNvidiaGPU [ ./nvidia-container-toolkit.nix ];

  virtualisation = {
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
    # waydroid
    waydroid.enable = true;
    # kvm
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        swtpm = {
          enable = true;
          package = pkgs.swtpm;
        };
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
