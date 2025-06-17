{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      ${
        config.zerozawa.ssh.machines
        |> lib.map (
          {
            host,
            port, # optional
            user, # optional
            ...
          }:
          ''
            Host ${host}
              HostName ${host}
              ${if port != null then "Port ${toString port}" else ""}
              ${if user != null then "User ${user}" else ""}
          ''
        )
        |> lib.concatStrings
      }
      # Common flags for all ${config.zerozawa.servers.teleport.address} hosts
      Host *.${config.zerozawa.servers.teleport.address} ${config.zerozawa.servers.teleport.address}
        UserKnownHostsFile ${config.home.homeDirectory}/.tsh/known_hosts
        IdentityFile "${config.home.homeDirectory}/.tsh/keys/${config.zerozawa.servers.teleport.address}/zerozawa"
        CertificateFile "${config.home.homeDirectory}/.tsh/keys/${config.zerozawa.servers.teleport.address}/zerozawa-ssh/${config.zerozawa.servers.teleport.address}-cert.pub"
      # Flags for all ${config.zerozawa.servers.teleport.address} hosts except the proxy
      Host *.${config.zerozawa.servers.teleport.address} !${config.zerozawa.servers.teleport.address}
        Port 3022
        ProxyCommand ${pkgs.teleport-lock.client}/bin/tsh proxy ssh --cluster=${config.zerozawa.servers.teleport.address} --proxy=${config.zerozawa.servers.teleport.address}:${toString config.zerozawa.servers.teleport.port} %r@%h:%p
      # End generated Teleport configuration
    '';
  };
}
