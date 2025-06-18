{
  pkgs,
  isNvidiaGPU,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    portalPackage = pkgs.hyprland-git-pkgs.xdg-desktop-portal-hyprland;
    package = pkgs.hyprland-git-pkgs.hyprland;
  };

}
