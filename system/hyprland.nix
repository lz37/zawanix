{
  pkgs,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland-git;
    package = pkgs.hyprland-git;
  };

}
