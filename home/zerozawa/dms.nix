{
  pkgs,
  inputs,
  ...
}: {
  programs.dankMaterialShell = {
    enable = true;
    systemd = {
      enable = false;
      restartIfChanged = false;
    };
    enableSystemMonitoring = true;
    enableVPN = false;
    quickshell.package = pkgs.quickshell.withModules (with pkgs.kdePackages; [
      kirigami
      kirigami-addons
      kirigami-gallery
    ]);
    plugins = with inputs; {
      WallpaperWatcherDaemon.src = "${dankMaterialShell}/PLUGINS/WallpaperWatcherDaemon";
      DankActions.src = "${dms-plugins}/DankActions";
      DankBatteryAlerts.src = "${dms-plugins}/DankBatteryAlerts";
      DankHooks.src = "${dms-plugins}/DankHooks";
      DankPomodoroTimer.src = "${dms-plugins}/DankPomodoroTimer";
    };
  };
}
