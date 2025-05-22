{
  inputs,
  system,
  ...
}:
let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in
{
  hardware.graphics = {
    enable = true;
    package = pkgs-hyprland.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs-hyprland.pkgsi686Linux.mesa;
  };
}
