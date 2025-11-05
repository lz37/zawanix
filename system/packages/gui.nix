{
  pkgs,
  lib,
  ...
}: let
  patchDesktop = import ./utils.nix {inherit pkgs lib;};
in {
  environment.systemPackages = with pkgs; [
    burpsuite
    thunderbird
    qq
    wiliwili
    telegram-desktop
    feishu
    wechat
    (
      patchDesktop wechat "wechat" ''^Exec=wechat %U''
      ''Exec=env XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U''
    )
    scrcpy
    android-studio
    rio
    # office
    # onlyoffice-desktopeditors
    libreoffice-qt6-fresh
    drawio
    jellyfin-media-player
    feishin
    gimp3
    pinta
    vlc
    dbeaver-bin
    remmina
    boxbuddy
    teams-for-linux
    figma-linux
    jamesdsp
    freerdp
    podman-desktop
    cherry-studio
    # wine
    # support both 32- and 64-bit applications
    wineWowPackages.stagingFull
    winetricks
    lutris
    protonplus
    mission-center
    qalculate-gtk
    lrcget
    waylyrics
    caffeine-ng
    ventoy-full-gtk
    wayvnc
    ndi
  ];
}
