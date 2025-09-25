{
  fetchurl,
  appimageTools,
  ...
}: let
  pname = "JMComic-qt";
  version = "1.2.9";
  src = fetchurl {
    url = "https://github.com/tonquer/${pname}/releases/download/v${version}/jmcomic_v${version}_linux-glibc2.38.AppImage";
    hash = "sha256-LgHR+HDfTb9Ur8p4Ibb8TUdLqwkK8wKynrKliYbEGSg=";
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
      cp ${appimageContents}/JMComic.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/JMComic.png $out/share/pixmaps/
      substituteInPlace $out/share/applications/JMComic.desktop --replace-fail 'Exec=JMComic' 'Exec=${pname}'
    '';
  }
