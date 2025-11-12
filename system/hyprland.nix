{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = pkgs.unstable-hyprland.packages.hyprland;
    portalPackage = pkgs.unstable-hyprland.packages.xdg-desktop-portal-hyprland;
  };
}
