{
  pkgs,
  lib,
  ...
}: let
  patchDesktop = import ./utils.nix {inherit pkgs lib;};
in {
  environment.systemPackages = with pkgs; [
    burpsuite
    nodecuda.thunderbird
    master.qq
    wiliwili
    telegram-desktop
    (master.feishu.override {
      commandLineArgs = ''
        "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
      '';
    })
    master.wechat
    (
      patchDesktop master.wechat "wechat" ''^Exec=wechat %U''
      ''Exec=env XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U''
    )
    scrcpy
    android-studio
    rio
    # office
    # onlyoffice-desktopeditors
    libreoffice-qt6-fresh
    drawio
    stable.jellyfin-media-player
    feishin
    gimp3
    pinta
    vlc
    dbeaver-bin
    remmina
    (boxbuddy.override {
      distrobox = distrobox_git;
    })
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
    discord
  ];
}
