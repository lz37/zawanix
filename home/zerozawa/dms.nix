{
  pkgs,
  inputs,
  isNvidiaGPU,
  lib,
  config,
  ...
}: let
  # 主显示器 HDMI-A-1
  # minimal kitty background config used by the panels
  baseBgKittyConf = ''
    font_family JetBrainsMono Nerd Font Mono
    background_opacity 0.0
    scrollbar never
  '';

  bgKittyCavaConf = pkgs.writeText "bg-kitty-cava-conf" (baseBgKittyConf
    + ''
      include ${config.xdg.configHome}/kitty/dank-theme.conf
      font_size 4.0
    '');

  bgKittyClockConf = pkgs.writeText "bg-kitty-clock-conf" (baseBgKittyConf
    + ''
      font_size 12.0
    '');
in {
  programs.dankMaterialShell = {
    enable = true;
    systemd = {
      enable = true;
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

  # Kitty kitten panels as separate user services
  systemd.user.services.kitty-panel-cava = {
    Unit = {
      Description = "Kitty background panel - Cava visualizer";
      PartOf = ["dms.service"];
      After = ["dms.service"];
    };
    Service = {
      Type = "exec";
      ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 15";
      ExecStart = "${lib.getExe' pkgs.kitty "kitten"} panel --edge=background -c ${bgKittyCavaConf} ${lib.getExe pkgs.cava}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  systemd.user.services.kitty-panel-clock = {
    Unit = {
      Description = "Kitty background panel - Clock";
      PartOf = ["dms.service"];
      After = ["dms.service"];
    };
    Service = {
      Type = "exec";
      ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 15";
      ExecStart = "${lib.getExe' pkgs.kitty "kitten"} panel --edge=background -c ${bgKittyClockConf} ${lib.getExe pkgs.clock-rs}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # 覆盖 DMS systemd service：添加环境变量并声明对 kitty-panel 的 Wants
  systemd.user.services.dms = {
    Unit = {
      Wants = ["kitty-panel-cava.service" "kitty-panel-clock.service"];
    };
    Service = {
      Environment =
        [
          "QS_DISABLE_DMABUF=1"
          "QT_QPA_PLATFORM=wayland"
        ]
        ++ (
          if isNvidiaGPU
          then ["DRI_PRIME=0"]
          else []
        );
    };
  };
}
