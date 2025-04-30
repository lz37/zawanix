{ config, ... }:

{
  imports = [
    ./programs.nix
    ./zsh
    ./services.nix
    ./xdg.nix
    ./neovim.nix
    ./vscode
    ./hyprland
    ./tmux.nix
    ./winapps
    ./podman.nix
    ./icon.nix
    ./plasma
    ./activation
    ./browser.nix
    ./electron.nix
  ];
  home = {
    stateVersion = config.zerozawa.version.home-manager-version;
  };
}
