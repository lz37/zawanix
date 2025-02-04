{ config, ... }:

{
  imports = [
    ../../options
    ./programs.nix
    ./zsh.nix
    ./services.nix
    ./xdg.nix
    ./neovim.nix
  ];
  home = {
    stateVersion = config.zerozawa.nixos.version;
  };
}
