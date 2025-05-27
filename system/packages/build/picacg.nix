{
  pkgs,
  stdenv,
  fetchurl,
  ...
}:
let
  pname = "picacg-qt";
  version = "v1.5.2";
  wrapper = ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.appimage-run}/bin/appimage-run $out/share/${pname}/${pname}.AppImage
  '';
  desktop = ''
    [Desktop Entry]
    Type=Application
    Name=PicACG
    Exec=${pkgs.appimage-run}/bin/appimage-run $out/share/${pname}/${pname}.AppImage
    Comment=PicACG
    Icon=$out/share/icons/hicolor/192x192/pixmaps/PicACG.png
    Categories=Graphics;
  '';
in
{
  inherit pname version;
  package = stdenv.mkDerivation (
    let
      appimage = "bika_${version}_linux_glibc2.38.AppImage";
    in
    rec {
      inherit pname version;
      dontBuild = true;
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      src = fetchurl {
        url = "https://github.com/tonquer/${pname}/releases/download/${version}/${appimage}";
        hash = "sha256-zAok08R9Xdx6z6JBGNoQlxPrSVvxkquYg9fgf8OMj1o=";
      };
      buildInputs = [
        pkgs.appimage-run
      ];
      installPhase = ''
        export TEMP_INSTALL=$(mktemp -d)
        mkdir -p $out/share/${pname}
        cp $src $out/share/${pname}/${pname}.AppImage
        mkdir -p $out/bin
        echo "${wrapper}" > $out/bin/${pname}
        chmod +x $out/bin/${pname}
        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/192x192/pixmaps
        ${pkgs.appimage-run}/bin/appimage-run -x $TEMP_INSTALL $out/share/${pname}/${pname}.AppImage
        cp $TEMP_INSTALL/PicACG.png $out/share/icons/hicolor/192x192/pixmaps/PicACG.png
        echo "${desktop}" > $out/share/applications/PicACG.desktop
        rm -rf $TEMP_INSTALL
      '';
    }
  );
}
