{
  pkgs,
  stdenv,
  fetchurl,
  ...
}:
let
  pname = "wechat";
  version = "4.0.1";
  wrapper = ''
    #!${pkgs.bash}/bin/bash
    XIM=fcitx
    GTK_IM_MODULE=fcitx
    QT_IM_MODULE=fcitx
    XMODIFIERS=@im=fcitx
    ${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
  '';
  desktop = ''
    [Desktop Entry]
    Categories=Utility;
    Comment=Wechat Desktop
    Comment[zh_CN]=微信桌面版
    Exec=XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx ${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
    Icon=$out/opt/${pname}/.DirIcon
    Name=${pname}
    Name[zh_CN]=微信
    StartupNotify=true
    Terminal=false
    Type=Application
    X-AppImage-Version=${version}
  '';
in
{
  inherit pname version;
  package = stdenv.mkDerivation ({
    inherit pname version;
    dontBuild = true;
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    src = fetchurl {
      url = "https://web.archive.org/web/20250512110825/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-gBWcNQ1o1AZfNsmu1Vi1Kilqv3YbR+wqOod4XYAeVKo=";
    };
    buildInputs = [
      pkgs.appimage-run
    ];
    nativeBuildInputs = [
      pkgs.appimage-run
    ];
    installPhase = ''
      runHook preInstall

      TEMP_INSTALL=$(mktemp -d)
      appimage-run -x $TEMP_INSTALL $src

      mkdir -p $out/bin
      echo "${wrapper}" > $out/bin/${pname}
      chmod +x $out/bin/${pname}

      mkdir -p $out/share/applications
      echo "${desktop}" > $out/share/applications/${pname}.desktop

      mkdir -p $out/opt
      cp -r $TEMP_INSTALL $out/opt/${pname}

      rm -rf $TEMP_INSTALL

      runHook postInstall
    '';
  });
}
