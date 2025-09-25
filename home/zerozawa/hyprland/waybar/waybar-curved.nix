{
  pkgs,
  lib,
  config,
  ...
}: let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  clock24h = true;
in {
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        "cffi/virtual-desktops" = {
          "module_path" = "${pkgs.waybar-vd}/libwaybar_vd.so";
          "format" = "{name}";
          "show_empty" = false;
          "show_window_count" = true;
        };
        "custom/waylrc" = {
          exec = ''${lib.getExe pkgs.waylrc} -p Feishin --external-lrc-provider=navidrome --external-lrc-provider=netease-cloud-music --navidrome-server-url="${config.zerozawa.navidrome.url}" --navidrome-username=${config.zerozawa.navidrome.username} --navidrome-password=${config.zerozawa.navidrome.password}'';
          return-type = "json";
          escape = true;
        };
        "custom/kdeconnect" = {
          tooltip = true;
          format = "{icon}";
          format-icons = "";
          exec-on-event = "true";
          on-click = "kdeconnect-app";
          tooltip-format = "KDE Connect";
        };
        modules-center = [
          "cffi/virtual-desktops" # 正常
          "hyprland/workspaces" # 正常
        ];
        layer = "top";
        position = "top";
        modules-left = [
          "custom/startmenu" # 正常
          "hyprland/window" # 正常
          "pulseaudio" # 正常
          "cpu" # 正常
          # "memory" # 正常
          # "disk" # 正常
          # "network" # 正常
          "idle_inhibitor" # 正常
          # "custom/media" # 正常
          # "mpris" # 正常
          "custom/waylrc" # 正常
        ];
        modules-right = [
          # "custom/waylrc" # 正常
          "custom/hyprbindings" # 正常
          "custom/notification" # 正常
          "custom/exit" # 正常
          "battery" # 正常
          "tray" # 正常
          "bluetooth" # 正常
          "custom/kdeconnect" # 正常
          "clock" # 正常
        ];
        "mpris" = {
          interval = 1;
          "format" = "{player_icon} {dynamic}";
          "format-paused" = "{status_icon} <i>{dynamic}</i>";
          "player-icons" = {
            "default" = "▶";
            "mpv" = "🎵";
          };
          "status-icons" = {
            "paused" = "⏸";
          };
        };
        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format =
            if clock24h == true
            then '' {:L%H:%M}''
            else '' {:L%I:%M %p}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          on-click = ''kitty "btop"'';
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          on-click = ''kitty "btop"'';
          tooltip = true;
        };
        "disk" = {
          format = "🖬 {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = true;
        };
        "tray" = {
          spacing = 12;
        };
        bluetooth = {
          format = "󰂯";
          # format-disabled = "󰂲";
          format-disabled = "";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} (󰥉 {device_battery_percentage}%)";
          tooltip-format = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected";
          tooltip-format-disabled = "bluetooth off";
          tooltip-format-connected = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t({device_battery_percentage}%)";
          max-length = 35;
          # on-click = "fish -c bluetooth_toggle";
          on-click = "${lib.getExe pkgs.overskride}";
        };
        "custom/media" = {
          tooltip = false;
          format = "{icon}󰎈";
          restart-interval = 2;
          return-type = "json";
          format-icons = {
            Playing = "";
            Paused = "";
          };
          max-length = 35;
          exec = ''playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "<i><span color='#a6da95'>{{playerName}}</span></i>: <b><span color='#f5a97f'>{{artist}}</span> - <span color='#c6a0f6'>{{markup_escape(title)}}</span></b>", "alt": "{{status}}", "class": "{{status}}" }' -F'';
          on-click = "playerctl play-pause";
          on-click-right = "playerctl next";
          on-click-middle = "playerctl prev";
          on-scroll-up = "playerctl volume 0.05-";
          on-scroll-down = "playerctl volume 0.05+";
          smooth-scrolling-threshold = "0.1";
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "⏻";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "";
          # exec = "rofi -show drun";
          on-click = "sleep 0.1 && rofi-launcher";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = "󱕴";
          on-click = "sleep 0.1 && list-keybinds";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = true;
        };
      }
    ];
    style = lib.concatStrings [
      ''
        #waybar-vd {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base01};
          margin: 4px 4px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #waybar-vd button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.5;
          transition: ${betterTransition};
        }
        #waybar-vd button.vdesk-focused {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #waybar-vd button.hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.8;
          transition: ${betterTransition};
        }
      ''
      ''
        * {
          font-family: "JetBrainsMono Nerd Font Mono", "LXGW WenKai Mono", monospace;
          font-size: 12px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: rgba(0,0,0,0);
        }
        #workspaces {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base01};
          margin: 4px 4px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.5;
          transition: ${betterTransition};
        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.8;
          transition: ${betterTransition};
        }
        tooltip {
          background: #${config.lib.stylix.colors.base00};
          border: 1px solid #${config.lib.stylix.colors.base08};
          border-radius: 12px;
        }
        tooltip label {
          color: #${config.lib.stylix.colors.base08};
        }
        #custom-media, #window, #pulseaudio, #cpu, #memory, #idle_inhibitor, #network, #disk, #mpris, #custom-waylrc {
          font-weight: bold;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 18px;
          background: #${config.lib.stylix.colors.base04};
          color: #${config.lib.stylix.colors.base00};
          border-radius: 24px 10px 24px 10px;
        }
        #custom-startmenu {
          color: #${config.lib.stylix.colors.base0B};
          background: #${config.lib.stylix.colors.base02};
          font-size: 28px;
          margin: 0px;
          padding: 0px 30px 0px 15px;
          border-radius: 0px 0px 40px 0px;
        }
        #custom-kdeconnect, #custom-kdeconnect, #custom-hyprbindings, #battery,
        #custom-notification, #tray, #custom-exit, #bluetooth {
          font-weight: bold;
          background: #${config.lib.stylix.colors.base0F};
          color: #${config.lib.stylix.colors.base00};
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 10px 24px 10px 24px;
          padding: 0px 18px;
        }
        #clock {
          font-weight: bold;
          color: #0D0E15;
          background: linear-gradient(90deg, #${config.lib.stylix.colors.base0E}, #${config.lib.stylix.colors.base0C});
          margin: 0px;
          padding: 0px 15px 0px 30px;
          border-radius: 0px 0px 0px 40px;
        }
      ''
    ];
  };
}
