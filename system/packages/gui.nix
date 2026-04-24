{
  pkgs,
  config,
  lib,
  ...
}: let
  patchDesktop = import ./utils.nix {inherit pkgs lib;};
  hw = config.zerozawa.hardware;
in {
  environment.systemPackages = with pkgs; [
    ssh-askpass-fullscreen
    rustdesk
    blueman
    burpsuite
    nogpu.thunderbird
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
      patchDesktop master.wechat "wechat" "^Exec=wechat %U"
      "Exec=env XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U"
    )
    master.wemeet
    scrcpy
    rio
    # office
    # onlyoffice-desktopeditors
    libreoffice-qt6-fresh
    drawio
    jellyfin-media-player
    fladder
    (switchfin.overrideAttrs (old: {
      cmakeFlags =
        if hw.isNvidiaGPU
        then map (flag: lib.replaceStrings ["-DUSE_EGL=ON"] ["-DUSE_EGL=OFF"] flag) (old.cmakeFlags or [])
        else old.cmakeFlags;
    }))
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
    wineWow64Packages.stagingFull
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
