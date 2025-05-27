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
    ${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
  '';
  desktop = ''
    [Desktop Entry]
    Categories=Utility;
    Comment=Wechat Desktop
    Comment[zh_CN]=微信桌面版
    Exec=${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
    Icon=$out/share/icons/hicolor/256x256/pixmaps/${pname}.png
    Name=${pname}
    Name[zh_CN]=微信
    StartupNotify=true
    Terminal=false
    Type=Application
    X-AppImage-Version=4.0.1
  '';
in
{
  inherit pname version;
  package = stdenv.mkDerivation (rec {
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
    installPhase = ''
      export TEMP_INSTALL=$(mktemp -d)
      ${pkgs.appimage-run}/bin/appimage-run -x $TEMP_INSTALL $src

      mkdir -p $out/bin
      echo "${wrapper}" > $out/bin/${pname}
      chmod +x $out/bin/${pname}

      mkdir -p $out/share/applications
      echo "${desktop}" > $out/share/applications/${pname}.desktop

      mkdir -p $out/share/icons/hicolor/256x256/pixmaps
      cp $TEMP_INSTALL/wechat.png $out/share/icons/hicolor/256x256/pixmaps/${pname}.png

      mkdir -p $out/opt
      cp -r $TEMP_INSTALL $out/opt/${pname}

      rm -rf $TEMP_INSTALL
    '';
  });
}
