{ pkgs, ... }:

{
  services = {
    fwupd.enable = true;
    dbus = {
      apparmor = "disabled";
      implementation = "dbus";
    };
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
        autoNumlock = true;
        enableHidpi = true;
        # sugarCandyNix = {
        #   ScreenWidth = 1920;
        #   ScreenHeight = 1080;
        #   ScaleImageCropped = true;
        #   FormPosition = "left";
        # };
      };
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
      defaultWindowManager = "startplasma-x11";
      openFirewall = true;
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
