{
  pkgs,
  stdenv,
  fetchurl,
  ...
}:
let
  pname = "JMComic-qt";
  version = "v1.2.8";
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
{
  inherit pname version;
  package = stdenv.mkDerivation (
    let
      appimage = "jmcomic_${version}_linux_glibc2.38.AppImage";
    in
    rec {
      inherit pname version;
      dontBuild = true;
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      src = fetchurl {
        url = "https://github.com/tonquer/${pname}/releases/download/${version}/${appimage}";
        hash = "";
      };
      buildInputs = [
        pkgs.appimage-run
        pkgs.xorg.libxcb
      ];
      installPhase = ''
        TEMP_INSTALL=$(mktemp -d)
        ${pkgs.appimage-run}/bin/appimage-run -x $TEMP_INSTALL $src

        mkdir -p $out/bin
        echo "${wrapper}" > $out/bin/${pname}
        chmod +x $out/bin/${pname}

        mkdir -p $out/share/applications
        echo "${desktop}" > $out/share/applications/${pname}.desktop

        mkdir -p $out/opt
        cp -r $TEMP_INSTALL $out/opt/${pname}

        rm -rf $TEMP_INSTALL
      '';
    }
  );
}
