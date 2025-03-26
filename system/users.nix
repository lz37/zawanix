{
  pkgs,
  config,
  ...
}:

{
  users.users.zerozawa = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "podman"
      "libvirtd"
      "adbusers"
    ];
    shell = "${pkgs.tmux}/bin/tmux";
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
          path = config.zerozawa.nixos.path.public;
          "writable" = "yes";
          "guest ok" = "yes";
          "public" = "yes";
          "force user" = "zerozawa";
        };
      };
    };
  };
}
