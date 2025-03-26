{
  ...
}:
{
  imports = [
    ./bluetooth.nix
    ./locale.nix
    ./programs.nix
    ./services.nix
    ./zram.nix
    ./virtualisation.nix
    ./nix.nix
    ./users.nix
    ./kernel.nix
    ./variables.nix
    ./audio.nix
    ./bootloader.nix
    ./packages
    ./flatpak.nix
    ./opengl.nix
    ./fs.nix
  ];
  system.stateVersion = (import ../options/variable-pub.nix).version.nixos;

}
