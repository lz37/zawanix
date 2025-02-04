{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    burpsuite
    kate
    thunderbird
    # qq
    # wechat-uos
    sonixd
    mpv
    # telegram-desktop
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
    vscode-fhs
    microsoft-edge
  ];
}
