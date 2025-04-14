{ pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "kde6";
    # style = "kvantum";
    kde.settings = {
      kwinrc = {
        Windows = {
          BorderlessMaximizedWindows = true;
        };
      };
      kdeglobals = {
        Icons = "Zafiro-Icons-Dark";
      };
    };
  };
  xdg.dataFile = {
    "icons/Zafiro-Icons-Dark" = {
      source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Dark";
      force = true;
    };
    "icons/Zafiro-Icons-Light" = {
      source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Light";
      force = true;
    };
  };

}
