{
  inputs,
  system,
  ...
}:
let
  pkgs-hyprland = inputs.hyprland.packages.${system};
in
{
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = pkgs-hyprland.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
  };
}
