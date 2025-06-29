{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
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
    # onlyoffice-desktopeditors
    libreoffice-qt6-fresh
    drawio
    jellyfin-media-player
    feishin
    gimp
    pinta
    vlc
    dbeaver-bin
    remmina
    boxbuddy
    teams-for-linux
    figma-linux
    jamesdsp
    freerdp3
    podman-desktop
    cherry-studio
    # wine
    # support both 32- and 64-bit applications
    wineWowPackages.stagingFull
    winetricks
    # protonplus
  ];
}
