{
  config,
  ...
}:
{
  imports = [
    ./bluetooth.nix
    ./locale.nix
    ./programs.nix
    ./services.nix
    ./zram.nix
    ./virtualisation
    ./nix.nix
    ./users.nix
    ./kernel.nix
    ./variables.nix
    ./audio.nix
    ./bootloader.nix
    ./packages
    ./opengl.nix
    ./fs.nix
    ./hyprland.nix
    ./sddm
    ./fonts
    ./xdg-portal.nix
    ./symlink.nix
  ];
  system.stateVersion = config.zerozawa.version.nixos;

}
