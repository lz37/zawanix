{
  config,
  lib,
  pkgs,
  ...
}: let
  no = "no";
in {
  programs.ssh = {
    enableDefaultConfig = false;
    settings =
      {
        "*" = {
          ForwardAgent = "no";
          AddKeysToAgent = no;
          Compression = "no";
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = "no";
          UserKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          ControlMaster = no;
          ControlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          ControlPersist = no;
        };
      }
      // (
        config.zerozawa.ssh.machines
        |> lib.map (
          {
            host,
            hostname,
            port, # optional
            user, # optional
            proxyJump, # optional
            identityFile, # optional
            ...
          }: {
            name = host;
            value = lib.filterAttrs (_: v: v != null) {
              Hostname =
                if hostname != null
                then hostname
                else host;
              Port = port;
              User = user;
              ProxyJump = proxyJump;
              IdentityFile = identityFile;
            };
          }
        )
        |> builtins.listToAttrs
      );
    enable = true;
    extraConfig = ''
      # Common flags for all ${config.zerozawa.servers.teleport.address} hosts
      Host *.${config.zerozawa.servers.teleport.address} ${config.zerozawa.servers.teleport.address}
        UserKnownHostsFile ${config.home.homeDirectory}/.tsh/known_hosts
        IdentityFile "${config.home.homeDirectory}/.tsh/keys/${config.zerozawa.servers.teleport.address}/zerozawa"
        CertificateFile "${config.home.homeDirectory}/.tsh/keys/${config.zerozawa.servers.teleport.address}/zerozawa-ssh/${config.zerozawa.servers.teleport.address}-cert.pub"
      # Flags for all ${config.zerozawa.servers.teleport.address} hosts except the proxy
      Host *.${config.zerozawa.servers.teleport.address} !${config.zerozawa.servers.teleport.address}
        Port 3022
        ProxyCommand ${pkgs.teleport.client}/bin/tsh proxy ssh --cluster=${config.zerozawa.servers.teleport.address} --proxy=${config.zerozawa.servers.teleport.address}:${toString config.zerozawa.servers.teleport.port} %r@%h:%p
      # End generated Teleport configuration
    '';
  };
}
