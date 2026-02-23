{pkgs, ...}: {
  services = {
    scx = {
      enable = true;
      package = pkgs.master.scx.full;
      scheduler = "scx_rusty";
    };
    xrdp = {
      enable = true;
      audio.enable = true;
      defaultWindowManager = "xfce4-session";
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        splix
      ];
    };
    glances = {
      enable = true;
      openFirewall = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    dbus = {
      apparmor = "disabled";
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
      desktopManager = {
        xfce = {
          enable = true;
          enableWaylandSession = true;
        };
      };
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
    sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = true;
    };
  };
}
