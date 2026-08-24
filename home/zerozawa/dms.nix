{
  pkgs,
  osConfig,
  ...
}: let
  hw = osConfig.zerozawa.hardware;
in {
  home.packages = with pkgs; [
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    xdg-utils
    linux-wallpaperengine
  ];
  # Nix store files always have mtime epoch 0, which defeats Qt's mtime-based
  # QML disk-cache validation: stale compiled units survive every plugin/shell
  # update (e.g. plugin settings UI failing to load with errors pointing at
  # lines that do not exist in the deployed file). Disable the QML disk cache.
  systemd.user.services.dms.Service.Environment = ["QML_DISABLE_DISK_CACHE=1"];

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
        wallpaperShufflerPlugin.enable = true;
        dankActions.enable = true;
        dankHooks.enable = true;
        dankBatteryAlerts.enable = true;
        dockerManager.enable = true;
        webSearch.enable = true;
        emojiLauncher.enable = true;
        commandRunner.enable = true;
        calculator.enable = true;
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
        linuxWallpaperEngine.enable = true;
        quickCapture.enable = true;
        dankKDEConnect.enable = true;
        gameControllerBattery.enable = true;
        dmsThemeSync.enable = true;
        aiOverviewControl.enable = true;
        screenCaptureToolbar.enable = true;
        dankConsoleSteam.enable = true;
        musicTheme.enable = true;
        systemMonitorPlus.enable = true;
        deepseekWidget.enable = true;
        dankHyprlandWindows.enable = true;
        steamFlagsPlugin.enable = true;
        hostnameWidget.enable = true;
        localServices.enable = true;
        enderPulse.enable = true;
        modernClock.enable = true;
        nextBootSelector.enable = true;
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
