{ inputs, pkgs, ... }@others:

let
  system-hyprland-settings = import ../../../system/hyprland.nix ({ inherit inputs pkgs; } // others);
in
{
  wayland.windowManager.hyprland = {
    inherit (system-hyprland-settings.programs.hyprland) enable package portalPackage;
  };
}
