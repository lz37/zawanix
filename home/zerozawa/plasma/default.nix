{ ... }:

{
  imports = [
    ./kwinrc.nix
    ./kdeglobals.nix
    ./krunnerrc.nix
    ./plasma-localerc.nix
    ./plasmanotifyrc.nix
    ./dolphin.nix
  ];
  programs.plasma.enable = true;
}
