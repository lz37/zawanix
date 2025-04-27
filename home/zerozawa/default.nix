{ ... }:

{
  imports = [
    ../../options
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
  ];
  home = {
    stateVersion = (import ../../options/variable-pub.nix).version.hm;
  };
}
