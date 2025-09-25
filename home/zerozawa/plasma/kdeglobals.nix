{...}: {
  programs.plasma.configFile.kdeglobals = {
    General = {
      fixed = "Hack,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      font = "Noto Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      menuFont = "Noto Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      smallestReadableFont = "Noto Sans,7,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      toolBarFont = "Noto Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      TerminalApplication = "kitty";
      TerminalService = "kitty.desktop";
    };
    Icons.Theme = "Zafiro-Icons-Dark";
  };
}
