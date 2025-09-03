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
    telegram-desktop_git
    (master.feishu.override {
      commandLineArgs = ''
        "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
      '';
    })
    master.wemeet
    master.wechat
    (patchDesktop master.wechat "wechat" ''^Exec=wechat %U''
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
    freerdp3
    podman-desktop
    cherry-studio
    # wine
    # support both 32- and 64-bit applications
    wineWowPackages.stagingFull
    winetricks
    lutris
    protonplus
    picacg-qt
    jmcomic-qt
    wechat-web-devtools-linux
    mission-center
    x2goclient
    qalculate-qt
    qalculate-gtk
    lrcget
    waylyrics
    caffeine-ng
  ];
}
