{ ... }:

{
  programs.plasma = {
    configFile = {
      yakuakerc = {
        Dialogs.FirstRun = false;
        Window.Width = 100;
      };
    };
    shortcuts.yakuake = {
      toggle-window-state = "Meta+`,F12,展开/折叠 Yakuake 窗口";
    };
  };
}
