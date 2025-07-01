{
  pkgs,
  lib,
  ...
}:
let
  patchDesktop = (import ./utils.nix { inherit pkgs lib; });
in
{
  environment.systemPackages = with pkgs; [
    burpsuite
    thunderbird
    master.qq
    wiliwili
    telegram-desktop
    master.wemeet
    master.wechat
    (patchDesktop master.wechat "wechat" ''^Exec=wechat %U''
      ''Exec=XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U''
    )
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
