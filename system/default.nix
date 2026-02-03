{inputs, ...}: {
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
    ./sddm
    ./fonts
    ./xdg-portal.nix
    ./hyprland.nix
    ./other-packages.nix
    ./clamav-scanner.nix
    ./facter.nix
    ./zerotier.nix
  ];
  system.stateVersion = inputs.nixpkgs.lib.trivial.release;
  documentation.nixos.enable = false;
}
