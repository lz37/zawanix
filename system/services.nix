{ pkgs, lib, ... }:

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
        # https://gitlab.com/Zhaith-Izaliel/sddm-sugar-candy-nix
        sugarCandyNix = {
          enable = true;
          settings = {
            Background = lib.cleanSource ./. + "../assets/15919563_95796589_p0_ツチヤ_天星.png";
            DimBackgroundImage = 0.2;
            ScreenWidth = 3840;
            ScreenHeight = 2160;
            ScaleImageCropped = true;
            FormPosition = "left";
            FullBlur = false;
            PartialBlur = true;
            BlurRadius = 100;
            HaveFormBackground = false;
            BackgroundImageHAlignment = "left";
            BackgroundImageVAlignment = "center";
            MainColor = "#1C3A59";
            # AccentColor =
            # BackgroundColor =
            # OverrideLoginButtonTextColor =
            InterfaceShadowSize = 6;
            InterfaceShadowOpacity = 0.6;
            RoundCorners = 20;
            ScreenPadding = 0;
            # Font=
            # FontSize=""
            ForceRightToLeft = false;
            ForceLastUser = true;
            ForcePasswordFocus = true;
            ForceHideVirtualKeyboardButton = false;
            ForceHideSystemButtons = false;
            # Locale=""
            HourFormat = "HH:mm:ss A t";
            DateFormat = "yyyy MMMM dd dddd";
            # 来点二次元的
            HeaderText = "欢迎使用 ZawaNix 喵\\(≧▽≦)/";
            TranslatePlaceholderUsername = "在这里输入用户名喵~";
            TranslatePlaceholderPassword = "在这里输入密码喵~";
            TranslateShowPassword = "按下就可以显示密码喵~";
            TranslateLogin = "登录喵~";
            TranslateLoginFailedWarning = "登录失败了喵(>_<)";
            TranslateCapslockWarning = "大写锁定开启了喵~";
            TranslateSession = "会话喵~";
            TranslateSuspend = "挂起喵~";
            TranslateHibernate = "休眠喵~";
            TranslateReboot = "重启喵~";
            TranslateShutdown = "关机喵~";
            TranslateVirtualKeyboardButton = "虚拟键盘喵~";
          };
        };
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
