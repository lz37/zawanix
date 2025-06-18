{
  config,
  pkgs,
  colorsh,
  ...
}:

{
  imports = [
    ./hyprland.nix
    ./anyrun.nix
  ];
}
