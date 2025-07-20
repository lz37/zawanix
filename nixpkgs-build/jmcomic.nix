{
  pkgs,
  stdenv,
  fetchurl,
  ...
}:
let
  pname = "JMComic-qt";
  version = "1.2.9";
  wrapper = ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
  '';
  desktop = ''
    [Desktop Entry]
    Type=Application
    Name=${pname}
    Exec=${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
    Comment=JMComic
    Icon=$out/opt/${pname}/.DirIcon
    Categories=Graphics;
  '';
in
stdenv.mkDerivation (
  let
    appimage = "jmcomic_v${version}_linux-glibc2.38.AppImage";
  in
  {
    inherit pname version;
    dontBuild = true;
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    src = fetchurl {
      url = "https://github.com/tonquer/${pname}/releases/download/v${version}/${appimage}";
      hash = "sha256-LgHR+HDfTb9Ur8p4Ibb8TUdLqwkK8wKynrKliYbEGSg=";
    };
    buildInputs = [
      pkgs.appimage-run
      pkgs.xorg.libxcb
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
  }
)
