{
  pkgs,
  isNvidiaGPU,
  lib,
  config,
  hostName,
  isLaptop,
  ...
}: let
  # minimal kitty background config used by the panels
  baseBgKittyConf = ''
    font_family JetBrainsMono Nerd Font Mono
    background_opacity 0.0
    scrollbar never
    include ${config.xdg.configHome}/kitty/dank-theme.conf
  '';

  bgKittyCavaConf = pkgs.writeText "bg-kitty-cava-conf" (baseBgKittyConf
    + ''
      font_size 4.0
    '');

  bgKittyClockConf = pkgs.writeText "bg-kitty-clock-conf" (baseBgKittyConf
    + ''
      font_size 18.0
    '');
in {
  home.packages = with pkgs; [
    (grimblast.override {
      hyprland = unstable-hyprland.packages.hyprland;
    })
    linux-wallpaperengine
    python3
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
        hyprlandSubmap.enable = true;
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
      }
      // (
        if isLaptop
        then {
          powerUsagePlugin.enable = true;
        }
        else {}
      );
    quickshell.package = pkgs.quickshell.withModules (with pkgs.kdePackages; [
      kirigami
      kirigami-addons
      kirigami-gallery
    ]);
  };
  systemd.user.services = let
    kitten = conf: exec: ''
      ${lib.getExe' pkgs.kitty "kitten"} panel --edge=background --output-name=${{
        zawanix-work = "DP-3";
        zawanix-glap = "eDP-1";
      }."${hostName}"} -c ${conf} "${exec}"
    '';
  in rec {
    kitty-panel-cava = {
      Unit = {
        Description = "Kitty background panel - Cava visualizer";
        PartOf = ["dms.service"];
        After = ["dms.service"];
      };
      Service = {
        Type = "exec";
        ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 15";
        ExecStart = kitten bgKittyCavaConf (lib.getExe pkgs.cava);
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
    kitty-panel-clock =
      kitty-panel-cava
      // {
        Unit =
          kitty-panel-cava.Unit
          // {
            Description = "Kitty background panel - Clock";
          };
        Service =
          kitty-panel-cava.Service
          // {
            ExecStart = kitten bgKittyClockConf (lib.getExe pkgs.clock-rs);
          };
      };
    dms = {
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
  };
}
