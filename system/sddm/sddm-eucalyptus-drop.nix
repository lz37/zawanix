{
  pkgs,
  lib,
  stdenv,
  fetchFromGitLab,
}:
{
  sddm-eucalyptus-drop = stdenv.mkDerivation {
    pname = "sddm-eucalyptus-drop";
    version = "v2.0.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sddm-eucalyptus-drop
      cp ${pkgs.writeText "$out/share/sddm/themes/sddm-eucalyptus-drop/theme.conf" ''
        [General]
        Background=${lib.cleanSource ../../. + "/assets/15919563_95796589_p0_ツチヤ_天星.png"}
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
        Font="Noto Sans"
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
      ''} $out/share/sddm/themes/sddm-eucalyptus-drop/theme.conf
    '';
    src = fetchFromGitLab {
      owner = "Matt.Jolly";
      repo = "sddm-eucalyptus-drop";
      rev = "c80e4fc24f229c21718d22ea7c498ccc3f54a4f7";
      sha256 = "";
    };
  };
}
