{
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # cli
    bun # needed by mcp
    uv # needed by mcp
    nodePackages.nodejs # needed by mcp
    exfatprogs
    xsel
    jq
    yq
    nettools
    busybox
    (lib.hiPrio uutils-coreutils-noprefix)
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
    fortune
    wakatime
    translate-shell
    p7zip
    unzip
    zip
    unar
    toolbox
    nmap
    # waydroid 剪贴版
    wl-clipboard
    cifs-utils
    cachix
    distrobox
    termsonic
    comma
    ipmitool
    teleport.client
    sshpass
    talosctl
  ];
}
