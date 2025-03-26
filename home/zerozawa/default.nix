{ ... }:

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
    stateVersion = (import ../../options/variable-pub.nix).version.hm;
  };
}
