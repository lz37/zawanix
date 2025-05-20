{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # cli
    xsel
    jq
    yq
    nettools
    busybox
    tcping-go
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
    unar
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
    # virt-viewer
    # spice
    # spice-gtk
    # spice-protocol
    # win-virtio
    # win-spice
    # virtiofsd
    # virglrenderer
    # samba
    cifs-utils
    cachix
    distrobox
    termsonic
    comma
    inputs.nixpkgs-teleport.legacyPackages.${stdenv.hostPlatform.system}.teleport.client
  ];
}
