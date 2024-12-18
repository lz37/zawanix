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
    ./fs.nix
    ./nix.nix
    ./users.nix
    ./chaotic.nix
    ./kernel.nix
    ./variables.nix
    ./packages
  ];
  system.stateVersion = config.zerozawa.nixos.version;

}
