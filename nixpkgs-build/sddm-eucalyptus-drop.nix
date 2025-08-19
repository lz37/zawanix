{
  pkgs,
  stdenv,
  fetchFromGitLab,
  libsForQt5,
  kdePackages,
  stylixImage,
  ...
}:

let
  theme-conf = ''
    [General]
    Background="${pkgs.lib.cleanSource stylixImage}"
    DimBackgroundImage="0.0"
    ScaleImageCropped="true"
    ScreenWidth="3840"
    ScreenHeight="2160"
    FullBlur="false"
    PartialBlur="true"
    BlurRadius="50"
    HaveFormBackground="false"
    FormPosition="left"
    BackgroundImageHAlignment="center"
    BackgroundImageVAlignment="center"
    MainColour="white"
    AccentColour="#DFA395"
    BackgroundColour="#C1AE87"
    OverrideLoginButtonTextColour=""
    InterfaceShadowSize="0"
    InterfaceShadowOpacity="0"
    RoundCorners="20"
    ScreenPadding="0"
    Font="Noto Sans"
    FontSize=""
    ForceRightToLeft="false"
    ForceLastUser="true"
    ForcePasswordFocus="true"
    ForceHideCompletePassword="false"
    ForceHideVirtualKeyboardButton="false"
    ForceHideSystemButtons="false"
    AllowEmptyPassword="false"
    AllowBadUsernames="false"
    Locale=""
    HourFormat="HH:mm"
    DateFormat="'今日は' yyyy MMMM dd dddd"
    HeaderText="ようこそ"
    TranslateCapslockWarning="大写锁定开启了喵~"
    TranslateHibernate=""
    TranslateLogin="登录喵~"
    TranslateLoginFailedWarning="登录失败了喵(>_<)"
    TranslatePlaceholderPassword="在这里输入密码喵~"
    TranslatePlaceholderUsername="在这里输入用户名喵~"
    TranslateReboot=""
    TranslateSession=""
    TranslateShowPassword="按下就可以显示密码喵~"
    TranslateShutdown=""
    TranslateSuspend=""
    TranslateVirtualKeyboardButton=""
  '';
  pname = "sddm-eucalyptus-drop";
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  inherit pname version;
  dontBuild = true;
  src = fetchFromGitLab {
    owner = "Matt.Jolly";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wq6V3UOHteT6CsHyc7+KqclRMgyDXjajcQrX/y+rkA0=";
  };
  propagatedUserEnvPkgs = [
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qtsvg
    kdePackages.qtbase
  ];
  installPhase = ''
    mkdir -p $out/share/sddm/themes/${pname}
    echo '${theme-conf}' > $out/share/sddm/themes/${pname}/theme.conf
    cp -Rn $src/* $out/share/sddm/themes/${pname}/
  '';
}
