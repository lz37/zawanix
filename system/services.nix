{ pkgs, ... }:

{
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        splix
      ];
    };
    udisks2.enable = true;
    fwupd.enable = true;
    dbus = {
      apparmor = "disabled";
      implementation = "broker";
    };
    desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };
    spice-vdagentd.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "cn";
        variant = "";
      };
    };
    xrdp = {
      enable = true;
      audio.enable = true;
      package = pkgs.xrdp.overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [ "--enable-glamor" ];
      });
      defaultWindowManager = "startplasma-x11";
      openFirewall = true;
    };
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
