{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # cli
    nettools
    linuxquota
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
    vulkan-loader
    vulkan-headers
    vulkan-tools
    # lang
    dart
    ## c/c++
    gnumake
    gcc
    # waydroid 剪贴版
    wl-clipboard
    # kvm
    virt-manager
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
  ];
}
