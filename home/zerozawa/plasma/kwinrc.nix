{ ... }:

{
  programs.plasma.configFile.kwinrc = {
    Wayland.InputMethod = {
      value = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
      shellExpand = true;
    };
    Windows.BorderlessMaximizedWindows = true;
    "org.kde.kdecoration2".theme = "Breeze 微风";
    Plugins = {
      desktopchangeosdEnabled = true;
      karouselEnabled = false;
      krohnkiteEnabled = false;
      kzonesEnabled = false;
      minimizeallEnabled = true;
      synchronizeskipswitcherEnabled = true;
      videowallEnabled = true;
    };
    Tiling.padding = 4;
  };
}
