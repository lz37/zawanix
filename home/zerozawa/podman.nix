{ config, ... }:

{
  services.podman = {
    enable = true;
    autoUpdate = {
      enable = true;
      onCalendar = "*-*-* 12,21:00:00";
    };
    containers = {
      winapps = {
        autoStart = true;
        environment = {
          VERSION = "11";
          RAM_SIZE = "4G"; # RAM allocated to the Windows VM.
          CPU_CORES = "2"; # CPU cores allocated to the Windows VM.
          DISK_SIZE = "64G"; # Size of the primary hard disk.
          #DISK2_SIZE: "32G" # Uncomment to add an additional hard disk to the Windows VM. Ensure it is mounted as a volume below.
          USERNAME = "zerozawa"; # Edit here to set a custom Windows username. The default is 'MyWindowsUser'.
          PASSWORD = "123456"; # Edit here to set a password for the Windows user. The default is 'MyWindowsPassword'.
          HOME = "${config.home.homeDirectory}"; # Set path to Linux user home folder.
          LANGUAGE = "Chinese";
        };
        image = "ghcr.io/dockur/windows:latest";
        addCapabilities = [ "NET_ADMIN" ];
        volumes = [
          "winapps-data:/storage"
          "${config.home.homeDirectory}:/shared"
        ];
        extraPodmanArgs = [
          "--device"
          "/dev/kvm"
          "--stop-timeout"
          "120"
        ];
        ports = [
          "8006:8006"
          "3389:3389/tcp"
          "3389:3389/udp"
        ];
      };
      aria2-pro = {
        autoStart = true;
        autoUpdate = "registry";
        environment = {
          RPC_SECRET = "aria2-pro";
          RPC_PORT = "6800";
          # no need for aria2 bt
          # LISTEN_PORT = "6888";
          UPDATE_TRACKERS = "false";
          DISK_CACHE = "256M";
          IPV6_MODE = "true";
          PUID = "0";
          PGID = "0";
        };
        image = "ghcr.io/p3terx/aria2-pro:latest";
        extraPodmanArgs = [
          "--network=host"
        ];
        volumes = [
          "${config.zerozawa.path.cfgRoot}/profile/aria2-pro:/config"
          "${config.zerozawa.path.downloads}:/downloads"
        ];
      };
    };
  };
}
