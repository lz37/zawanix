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
    ./fonts
    ./winapps
    ./podman.nix
    ./theme.nix
  ];
  home = {
    stateVersion = (import ../../options/variable-pub.nix).version.hm;
  };
}
