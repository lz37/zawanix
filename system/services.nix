{ ... }:

{
  services = {
    scx.enable = true;
    qemuGuest.enable = true;
    rpcbind.enable = true; # needed for NFS
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        GatewayPorts = "yes";
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
      allowSFTP = true;
      extraConfig = ''
        AllowTcpForwarding yes
        TCPKeepAlive yes
      '';
    };
  };

}
