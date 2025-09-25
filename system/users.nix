{
  config,
  pkgs,
  ...
}: {
  users.users = {
    zerozawa = {
      uid = config.zerozawa.users.zerozawa.uid;
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "podman"
        "kvm"
        "libvirtd"
        "adbusers"
        "video"
        "input"
        "render"
        "xrdp"
      ];
      shell = "${pkgs.zsh}/bin/zsh";
    };
  };
  services = {
    samba-wsdd.enable = true;
    samba = {
      enable = true;
      nmbd.enable = true;
      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          security = "user";
          workgroup = "WORKGROUP";
          "server string" = "Samba Server";
          "server role" = "standalone server";
          "dns proxy" = "no";
          "map to guest" = "Bad User";
        };
        public = {
          browseable = "yes";
          path = config.zerozawa.path.public;
          "writable" = "yes";
          "guest ok" = "yes";
          "public" = "yes";
          "force user" = "zerozawa";
        };
      };
    };
  };
}
