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
  ];
}
