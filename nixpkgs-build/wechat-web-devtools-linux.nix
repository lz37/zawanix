{
  fetchurl,
  appimageTools,
  ...
}:
let
  pname = "wechat-web-devtools-linux";
  version = "1.06.2504010-2";
  src = fetchurl {
    url = "https://github.com/msojocs/${pname}/releases/download/v${version}/WeChat_Dev_Tools_v${version}_x86_64_linux.AppImage";
    # hash = "sha256-LgHR+HDfTb9Ur8p4Ibb8TUdLqwkK8wKynrKliYbEGSg=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/io.github.msojocs.wechat_devtools.desktop $out/share/applications/
    mkdir -p $out/share/pixmaps
    cp ${appimageContents}/wechat-devtools.png $out/share/pixmaps/
    substituteInPlace $out/share/applications/io.github.msojocs.wechat_devtools.desktop --replace-fail 'Exec=bin/wechat-devtools' 'Exec=${pname}'
  '';
}
