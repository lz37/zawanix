{
  pkgs,
  inputs,
  ...
}: {
  programs.dankMaterialShell = {
    enable = true;
    enableSystemd = false;
    enableVPN = false;
    quickshell.package = pkgs.quickshell.withModules (with pkgs.kdePackages; [
      kirigami
      kirigami-addons
      kirigami-gallery
    ]);
    plugins = with inputs; {
      ControlCenterDetailExample.src = "${dankMaterialShell}/PLUGINS/ControlCenterDetailExample";
      ControlCenterExample.src = "${dankMaterialShell}/PLUGINS/ControlCenterExample";
      ExampleEmojiPlugin.src = "${dankMaterialShell}/PLUGINS/ExampleEmojiPlugin";
      ExampleWithVariants.src = "${dankMaterialShell}/PLUGINS/ExampleWithVariants";
      LauncherExample.src = "${dankMaterialShell}/PLUGINS/LauncherExample";
      PopoutControlExample.src = "${dankMaterialShell}/PLUGINS/PopoutControlExample";
      WallpaperWatcherDaemon.src = "${dankMaterialShell}/PLUGINS/WallpaperWatcherDaemon";
      DankActions.src = "${dms-plugins}/DankActions";
      DankBatteryAlerts.src = "${dms-plugins}/DankBatteryAlerts";
      DankHooks.src = "${dms-plugins}/DankHooks";
      DankPomodoroTimer.src = "${dms-plugins}/DankPomodoroTimer";
    };
  };
}
