{
  pkgs,
  isNvidiaGPU,
  lib,
  ...
}:

let
  HOME = "${(import ../options/variable-pub.nix).path.home}";
in

{

  imports = lib.optionals isNvidiaGPU [ ./nvidia-container-toolkit.nix ];

  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        winapps = {
          image = "ghcr.io/dockur/windows:latest";
          environment = {
            VERSION = "tiny11";
            RAM_SIZE = "4G";
            CPU_CORES = "4";
            DISK_SIZE = "64G";
            USERNAME = "zerozawa";
            PASSWORD = "123456";
            inherit HOME;
          };
          volumes = [
            "winapps-data:/storage"
            "${HOME}:/shared"
            "${HOME}/oem:/oem"
          ];
          extraOptions = [
            "--privileged"
            "--device"
            "/dev/kvm"
            "--stop-timeout"
            "120"
          ];
          ports = [
            "8006:8006"
            "3389:3389/udp"
            "3389:3389/tcp"
          ];
        };
      };
    };
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
