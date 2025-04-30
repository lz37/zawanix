{ pkgs, ... }:
{

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];
  };
}
