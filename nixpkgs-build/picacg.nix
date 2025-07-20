{
  pkgs,
  stdenv,
  fetchurl,
  ...
}:
let
  pname = "picacg-qt";
  version = "1.5.2";
  wrapper = ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
  '';
  desktop = ''
    [Desktop Entry]
    Type=Application
    Name=${pname}
    Exec=${pkgs.appimage-run}/bin/appimage-run -w $out/opt/${pname}
    Comment=PicACG
    Icon=$out/opt/${pname}/.DirIcon
    Categories=Graphics;
  '';
in
{
  inherit pname version;
  package = stdenv.mkDerivation (
    let
      appimage = "bika_v${version}_linux_glibc2.38.AppImage";
    in
    {
      inherit pname version;
      dontBuild = true;
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      src = fetchurl {
        url = "https://github.com/tonquer/${pname}/releases/download/v${version}/${appimage}";
        hash = "sha256-zAok08R9Xdx6z6JBGNoQlxPrSVvxkquYg9fgf8OMj1o=";
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
  );
}
