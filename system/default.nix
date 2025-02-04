{
  config,
  ...
}:

{
  imports = [
    ./grub.nix
    ./network.nix
    ./locale.nix
    ./programs.nix
    ./services.nix
    ./zram.nix
    ./virtualisation.nix
    ./nix.nix
    ./users.nix
    ./kernel.nix
    ./variables.nix
    ./hyprland.nix
    ./audio.nix
    ./packages
  ];
  system.stateVersion = config.zerozawa.nixos.version;

}
