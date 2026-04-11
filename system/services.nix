{
  pkgs,
  config,
  isGameMachine,
  isIntelCPU,
  isAMDCPU,
  isLaptop,
  ...
}: {
  services = {
    hardware.openrgb = {
      enable = isGameMachine && !isLaptop;
      motherboard =
        if isIntelCPU
        then "intel"
        else if isAMDCPU
        then "amd"
        else null;
      package = pkgs.openrgb-with-all-plugins;
    };
    scx = {
      enable = true;
      package = pkgs.master.scx.full;
      scheduler = "scx_rusty";
    };
    xrdp = {
      enable = true;
      audio.enable = true;
      defaultWindowManager = "openbox-session";
    };
    rustdesk-server =
      if config.zerozawa.network != null && config.zerozawa.network.static-address != null
      then {
        enable = true;
        openFirewall = true;
        signal.relayHosts = ["localhost" config.zerozawa.network.static-address];
      }
      else {enable = false;};
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
    gnome.gnome-keyring.enable = false;
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
      windowManager = {
        openbox.enable = true;
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
      # package = pkgs.sunshine.override {
      #   boost = pkgs.boost187;
      # };
    };
  };
}
