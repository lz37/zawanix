{ ... }:

{
  services = {
    scx.enable = true;
    displayManager.sddm.enable = true;
    xserver={
      enable = true;
      xkb = {
        layout = "cn";
        variant = "";
      };
    };
    printing.enable = true;
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
