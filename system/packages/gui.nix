{
  pkgs,
  pkgs-master,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    burpsuite
    thunderbird
    pkgs-master.qq
    pkgs-master.wiliwili
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
    pkgs-master.feishin
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
    kitty
    # jamesdsp
  ];
}
