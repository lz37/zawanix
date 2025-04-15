{ ... }:

{
  services.podman = {
    enable = true;
    autoUpdate = {
      enable = true;
      onCalendar = "*-*-* 12,21:00:00";
    };
    containers = {
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
          "${(import ../../options/variable-pub.nix).path.cfgRoot}/profile/aria2-pro:/config"
          "${(import ../../options/variable-pub.nix).path.downloads}:/downloads"
        ];
      };
    };
  };
}
