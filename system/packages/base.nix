{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # cli
    tmux
    nettools
    busybox
    tcping-go
    mysql80
    lua
    ffmpeg
    rar
    vim
    wget
    git
    zsh
    btop
    fastfetch
    neovim
    tree
    podman-compose
    openjpeg
    thefuck
    fortune
    wakatime
    translate-shell
    p7zip
    unzip
    zip
    toolbox
    nmap
    # lang
    dart
    ## c/c++
    gnumake
    gcc
    # waydroid 剪贴版
    wl-clipboard
    # kvm
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    # win-virtio
    # win-spice
    virtiofsd
    virglrenderer
    # samba
    cifs-utils
    cachix
    distrobox
    # wine
    # support both 32- and 64-bit applications
    # wineWowPackages.waylandFull
    # winetricks
    mihomo
    termsonic
    wirelesstools
  ];
}
