{
  pkgs,
  osConfig,
  ...
}: let
  hw = osConfig.zerozawa.hardware;
in {
  home.packages = with pkgs; [
    grimblast
    linux-wallpaperengine
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    xdg-utils
  ];
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = false;
    };
    enableSystemMonitoring = true;
    enableVPN = false;
    plugins =
      {
        desktopCommand.enable = true;
        gitmojiLauncher.enable = true;
        mediaPlayer.enable = true;
        wallpaperDiscovery.enable = true;
        alarmClock.enable = true;
        linuxWallpaperEngine.enable = true;
        nixMonitor.enable = true;
        wallpaperShufflerPlugin.enable = true;
        dankActions.enable = true;
        dankHooks.enable = true;
        dankBatteryAlerts.enable = true;
        dockerManager.enable = true;
        webSearch.enable = true;
        emojiLauncher.enable = true;
        commandRunner.enable = true;
        calculator.enable = true;
        grimblast.enable = true;
        githubHeatmap.enable = true;
        githubNotifier.enable = true;
        musicLyrics.enable = true;
        developerUtilities.enable = true;
        chineseCalendar.enable = true;
        animeCalendar.enable = true;
        usbManager.enable = true;
        fullscreenPowerMenu.enable = true;
        aiAssistant.enable = true;
        screenRecorder.enable = true;
        dankLauncherKeys.enable = true;
        dankRssWidget.enable = true;
        vscodeLauncher.enable = true;
        cavaVisualizer.enable = true;
      }
      // (
        if hw.isLaptop
        then {
          powerUsagePlugin.enable = true;
        }
        else {}
      );
    quickshell.package = pkgs.quickshell.withModules (
      with pkgs.kdePackages; [
        kirigami
        kirigami-addons
        kirigami-gallery
      ]
    );
  };
}
