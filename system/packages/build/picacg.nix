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
    #!$out/bin/bash
    appimage-run $out/share/picacg-qt/picacg-qt.AppImage
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
        pkgs.xorg.libxcb
        pkgs.appimage-run
        pkgs.bash
      ];
      installPhase = ''
        mkdir -p $out/share/picacg-qt
        cp $src $out/share/picacg-qt/picacg-qt.AppImage
        mkdir -p $out/bin
        echo "${wrapper}" > $out/bin/picacg-qt
        chmod +x $out/bin/picacg-qt
        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/192x192
        mkdir -p $out/tmp
        appimage-run -x $out/tmp $src
        cp $out/tmp/PicACG.png $out/share/icons/hicolor/192x192/pixmaps/PicACG.png
        cp $out/tmp/PicACG.desktop $out/share/applications/PicACG.desktop
        rm -rf $out/tmp
      '';
    }
  );
}
