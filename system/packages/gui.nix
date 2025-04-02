{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages =
    (with pkgs; [
      burpsuite
      thunderbird
      qq
      wiliwili
      telegram-desktop
      wemeet
      # wechat-uos
      mpv
      scrcpy
      android-studio
      rio
      # office
      # onlyoffice-bin
      # calibre
      wpsoffice-cn
      drawio
      # libreoffice-qt
      jellyfin-media-player
      feishin
      gimp
      pinta
      vlc
      obs-studio
      dbeaver-bin
      remmina
      boxbuddy
      teams-for-linux
      figma-linux
      microsoft-edge
      jamesdsp
      freerdp3
      # wine
      # support both 32- and 64-bit applications
      # wineWowPackages.stagingFull
      # winetricks
      # protonplus
    ])
    ++ [
      inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps
      inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps-launcher # optional
    ];
}
