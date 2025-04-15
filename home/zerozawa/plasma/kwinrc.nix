{ pkgs, ... }:

{
  programs.plasma.configFile.kwinrc = {
    Wayland."InputMethod[$e]" =
      "${pkgs.kdePackages.fcitx5-with-addons}/share/applications/fcitx5-wayland-launcher.desktop";
    Windows.BorderlessMaximizedWindows = true;
  };
}
