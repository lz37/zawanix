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
      onlyoffice-desktopeditors
      # calibre
      wpsoffice-cn
      # libreoffice-qt6-fresh
      drawio
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
      stable.jamesdsp
      freerdp3
      podman-desktop
      google-chrome
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
