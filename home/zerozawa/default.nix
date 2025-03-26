{ config, ... }:

{
  imports = [
    ../../options
    ./programs.nix
    ./zsh.nix
    ./services.nix
    ./xdg.nix
    ./neovim.nix
    ./vscode
    ./hyprland
    ./tmux.nix
  ];
  home = {
    stateVersion = config.zerozawa.nixos.home-manager-version;
  };
}
