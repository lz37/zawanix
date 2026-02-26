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
    matchBlocks =
      {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = no;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          controlMaster = no;
          controlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          controlPersist = no;
        };
      }
      // (
        config.zerozawa.ssh.machines
        |> lib.map (
          {
            host,
            port, # optional
            user, # optional
            proxyJump, # optional
            ...
          }: {
            name = host;
            value = {
              hostname = host;
              inherit port user proxyJump;
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
