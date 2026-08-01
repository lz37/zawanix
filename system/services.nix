{
  lib,
  pkgs,
  config,
  ...
}: let
  hw = config.zerozawa.hardware;
  host = config.zerozawa.host;
in {
  services = {
    hardware.openrgb = {
      enable = host.isGameMachine && !hw.isLaptop;
      motherboard =
        if hw.isIntelCPU
        then "intel"
        else if hw.isAMDCPU
        then "amd"
        else null;
      package = pkgs.openrgb-with-all-plugins;
    };
    scx = {
      enable = true;
      package = pkgs.master.scx.full;
      # 性能最猛：scx_lavd（LAVD 延迟敏感 deadline 调度，专为游戏交互优化）
      scheduler = "scx_lavd";
      # 按硬件形态选择功耗档：
      # - 台式机（有无独显）→ 性能档，桌面/游戏保持满血
      # - 笔记本 + OCuLink eGPU → 性能档
      # - 笔记本无独显（移动/日常，如高铁上看视频）→ autopilot 自动档，空闲省电、负载自适应
      extraArgs =
        if hw.isLaptop && !host.isGameMachine && !hw.isOculink
        then ["--autopilot"]
        else ["--performance"];
    };
    xrdp = {
      enable = true;
      audio.enable = true;
      defaultWindowManager = "openbox-session";
    };
    rustdesk-server =
      if !config.networking.networkmanager.enable && !config.networking.useDHCP
      then {
        enable = true;
        openFirewall = true;
        signal.relayHosts =
          [
            "localhost"
          ]
          ++ builtins.concatLists (
            lib.mapAttrsToList (
              _: iface: map (addr: addr.address) (iface.ipv4.addresses or [])
            )
            config.networking.interfaces
          );
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
    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = false;
    };
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
