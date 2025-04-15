{ ... }:

{
  imports = [
    ./kwinrc.nix
    ./kdeglobals.nix
    ./krunnerrc.nix
    ./plasma-localerc.nix
    ./plasmanotifyrc.nix
    ./yakuake.nix
    ./dolphin.nix
  ];
  programs.plasma.enable = true;
}
