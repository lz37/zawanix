{
  config,
  ...
}:

{
  imports = [
    ./bluetooth.nix
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
    ./bootloader.nix
    ./packages
    ./flatpak.nix
    ./opengl.nix
    ./fs.nix
  ];
  system.stateVersion = config.zerozawa.nixos.version;

}
