{ config, ... }:

{
  imports = [
    ../../options
    ./programs.nix
    ./zsh.nix
  ];
  home = {
    stateVersion = config.zerozawa.nixos.version;
  };
}
