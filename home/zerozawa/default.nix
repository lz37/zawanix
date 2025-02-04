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
  ];
  home = {
    stateVersion = config.zerozawa.nixos.version;
  };
}
