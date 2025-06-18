{
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    package = pkgs.hyprland-git-nixpkgs-pkgs.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs.hyprland-git-nixpkgs-pkgs.pkgsi686Linux.mesa;
  };
}
