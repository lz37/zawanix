{
  pkgs,
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
      "kvm"
      "libvirt"
      "adbusers"
    ];
    shell = "${(pkgs.writeScriptBin "choose-shell" ''
      #!${pkgs.bash}/bin/bash
      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        SHELL="${pkgs.zsh}/bin/zsh";
      else
        SHELL="${pkgs.tmux}/bin/tmux";
      fi
      exec "$SHELL" "$@"
    '')}/bin/choose-shell";
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
          path = (import ../options/variable-pub.nix).path.public;
          "writable" = "yes";
          "guest ok" = "yes";
          "public" = "yes";
          "force user" = "zerozawa";
        };
      };
    };
  };
}
