{
  fetchurl,
  appimageTools,
  ...
}: let
  pname = "picacg-qt";
  version = "1.5.2";
  src = fetchurl {
    url = "https://github.com/tonquer/${pname}/releases/download/v${version}/bika_v${version}_linux_glibc2.38.AppImage";
    hash = "sha256-zAok08R9Xdx6z6JBGNoQlxPrSVvxkquYg9fgf8OMj1o=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    src = appimageContents;
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libxcb
      ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/PicACG.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/PicACG.png $out/share/pixmaps/
      substituteInPlace $out/share/applications/PicACG.desktop --replace-fail 'Exec=PicACG' 'Exec=${pname}'
    '';
  }
