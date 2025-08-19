{
  pkgs,
  config,
  isNvidiaGPU,
  hostName,
  lib,
  ...
}:

let
  and = x: "${x} &";
  mainMod = "SUPER";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
    settings =
      let
        cmd = {
          hyprctl = lib.getExe' pkgs.hyprland-git-pkgs.hyprland "hyprctl";
          ags = lib.getExe' pkgs.illogical-impulse.agsPackage "ags";
          "record-script.sh" = "${pkgs.illogical-impulse.ags}/scripts/record-script.sh";
          pkill = lib.getExe' pkgs.procps "pkill";
          wlogout = lib.getExe' pkgs.wlogout "wlogout";
          jq = lib.getExe' pkgs.jq "jq";
          grim = lib.getExe' pkgs.grim "grim";
          slurp = lib.getExe' pkgs.slurp "slurp";
          tesseract = lib.getExe' pkgs.tesseract "tesseract";
          wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
          easyeffects = lib.getExe' pkgs.easyeffects "easyeffects";
          anyrun = lib.getExe' pkgs.anyrun-git-pkgs.anyrun "anyrun";
          "switchwall.sh" = "${pkgs.illogical-impulse.ags}/scripts/color_generation/switchwall.sh";
          pavucontrol = lib.getExe' pkgs.pavucontrol "pavucontrol";
          "workspace_action.sh" = "${pkgs.illogical-impulse.ags}/scripts/hyprland/workspace_action.sh";
          notify-send = lib.getExe' pkgs.notify "notify-send";
          fuzzel = lib.getExe' pkgs.fuzzel "fuzzel";
          "primary-buffer-query.sh" = "${pkgs.illogical-impulse.ags}/scripts/primary-buffer-query.sh";
          playerctl = lib.getExe' pkgs.playerctl "playerctl";
          bc = lib.getExe' pkgs.busybox "bc";
          swappy = lib.getExe' pkgs.swappy "swappy";
          cliphist = lib.getExe' pkgs.cliphist "cliphist";
          wpctl = lib.getExe' pkgs.wireplumber "wpctl";
          sleep = lib.getExe' pkgs.uutils-coreutils-noprefix "sleep";
          "grimblast.sh" = "${pkgs.illogical-impulse.ags}/scripts/grimblast.sh";
          date = lib.getExe' pkgs.uutils-coreutils-noprefix "date";
          killall = lib.getExe' pkgs.busybox "killall";
        };
      in
      {
        exec-once = [
          (and (lib.getExe' pkgs.kdePackages.kwallet-pam "pam_kwallet_init"))
          (and "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1")
          (and (lib.getExe' pkgs.kdePackages.polkit-kde-agent-1 "kwalletd6"))
          (and ((lib.getExe' pkgs.swww "swww-daemon") + " --format xrgb"))
          (and (lib.getExe pkgs.waybar-git))
          (and (lib.getExe pkgs.illogical-impulse.ags-launcher))
          # (and (lib.getExe pkgs.fcitx5))
          (and (lib.getExe pkgs.hypridle))
          (and ((lib.getExe' pkgs.dbus "dbus-update-activation-environment") + " --all"))
          (and "${lib.getExe' pkgs.uutils-coreutils-noprefix "sleep"} 1 && ${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
          (and ((lib.getExe pkgs.easyeffects) + " --gapplication-service"))
          (and ((lib.getExe' pkgs.wl-clipboard "wl-paste ") + " --type text --watch cliphist store"))
          (and ((lib.getExe' pkgs.wl-clipboard "wl-paste ") + " --type image --watch cliphist store"))
        ]
        ++ (lib.optionals (hostName != "zawanix-work") [
          (and (lib.getExe' pkgs.networkmanagerapplet "nm-applet"))
        ]);
        general = {
          # Gaps and border
          gaps_in = 4;
          gaps_out = 5;
          gaps_workspaces = 50;
          border_size = 1;
          # Fallback colors
          "col.active_border" = "rgba(0DB7D4FF)";
          "col.inactive_border" = "rgba(31313600)";
          resize_on_border = true;
          no_focus_fallback = true;
          layout = "dwindle";
          #focus_to_other_workspaces = true # ahhhh i still haven't properly implemented this
          allow_tearing = true; # This just allows the `immediate` window rule to work
        };
        dwindle = {
          preserve_split = true;
          smart_split = false;
          smart_resizing = false;
        };
        gestures = {
          workspace_swipe = true;
          workspace_swipe_distance = 700;
          workspace_swipe_fingers = 4;
          workspace_swipe_cancel_ratio = 0.2;
          workspace_swipe_min_speed_to_force = 5;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = true;
        };
        input = {
          # Keyboard: Add a layout and uncomment kb_options for Win+Space switching shortcut
          kb_layout = "us";
          # kb_options = grp:win_space_toggle;
          numlock_by_default = true;
          repeat_delay = 250;
          repeat_rate = 35;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
            scroll_factor = 0.5;
          };
          special_fallthrough = true;
          follow_mouse = 1;
        };
        decoration = {
          rounding = 20;
          active_opacity = 1.0;
          inactive_opacity = 0.8;
          fullscreen_opacity = 1.0;
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            new_optimizations = "on";
            ignore_opacity = true;
            xray = true;
          };
          # Shadow
          shadow = {
            enabled = true;
            range = 30;
            render_power = 3;
            color = "0x66000000";
          };
        };
        animations = {
          enabled = true;
          bezier = [
            "linear, 0, 0, 1, 1"
            "md3_standard, 0.2, 0, 0, 1"
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "crazyshot, 0.1, 1.5, 0.76, 0.92 "
            "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.38, 0.04, 1, 0.07"
            "easeInOutCirc, 0.85, 0, 0.15, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutExpo, 0.16, 1, 0.3, 1"
            "softAcDecel, 0.26, 0.26, 0.15, 1"
            "md2, 0.4, 0, 0.2, 1" # use with .2s duration
          ];
          animation = [
            "windows, 1, 3, md3_decel, popin 60%"
            "windowsIn, 1, 3, md3_decel, popin 60%"
            "windowsOut, 1, 3, md3_accel, popin 60%"
            "border, 1, 10, default"
            "fade, 1, 3, md3_decel"
            # "layers, 1, 2, md3_decel, slide"
            "layersIn, 1, 3, menu_decel, slide"
            "layersOut, 1, 1.6, menu_accel"
            "fadeLayersIn, 1, 2, menu_decel"
            "fadeLayersOut, 1, 0.5, menu_accel"
            "workspaces, 1, 7, menu_decel, slide"
            # "workspaces, 1, 2.5, softAcDecel, slide"
            # "workspaces, 1, 7, menu_decel, slidefade 15%"
            # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
            "specialWorkspace, 1, 3, md3_decel, slidevert"
          ];
        };
        misc = {
          vfr = 1;
          vrr = 1;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          enable_swallow = false;
          swallow_regex = "(foot|kitty|allacritty|Alacritty)";

          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          new_window_takes_over_fullscreen = 2;
          allow_session_lock_restore = true;

          initial_workspace_tracking = false;
        };
        bind =

          [
            "Alt, Tab, bringactivetotop, "
            "Alt, Tab, cyclenext"
            ''
              Ctrl+Alt, Delete, exec, for ((i=0; i<$(${cmd.hyprctl} monitors -j | ${cmd.jq} length); i++)); do ${cmd.ags} -t "session""$i"; done
            ''
            "Ctrl+Alt, R, exec, ${cmd."record-script.sh"} --fullscreen"
            "Ctrl+Alt, Slash, exec, ${cmd.ags} run-js 'cycleMode();'"
            "Ctrl+Shift+Alt, Delete, exec, ${cmd.pkill} wlogout || ${cmd.wlogout} -p layer-shell"
            "Ctrl+Shift+Alt+Super, Delete, exec, systemctl poweroff || loginctl poweroff"
            # "Ctrl+Shift, Escape, exec, gnome-system-monitor"
            "Ctrl+Super+Alt, Left, workspace, m-1"
            "Ctrl+Super+Alt, Right, workspace, m+1"
            "Ctrl+Super, Backslash, resizeactive, exact 640 480"
            "Ctrl+Super, BracketLeft, workspace, -1"
            "Ctrl+Super, BracketRight, workspace, +1"
            "Ctrl+Super, Down, workspace, r+5"
            ''
              Ctrl+Super, G, exec, for ((i=0; i<$(${cmd.hyprctl} monitors -j | ${cmd.jq} length); i++)); do ${cmd.ags} -t"crosshair""$i"; done
            ''
            "Ctrl+Super, Left, workspace, r-1"
            "Ctrl+Super, L, exec, ${cmd.ags} run-js 'lock.lock()'"
            "Ctrl+Super, mouse_down, workspace, r-1"
            "Ctrl+Super, mouse_up, workspace, r+1"
            "Ctrl+Super, Page_Down, workspace, r+1"
            "Ctrl+Super, Page_Up, workspace, r-1"
            "Ctrl+Super, Right, workspace, r+1"
            "Ctrl+Super+Shift, Left, movetoworkspace, r-1"
            "Ctrl+Super+Shift, Right, movetoworkspace, r+1"
            ''
              Ctrl+Super+Shift,S,exec,${cmd.grim} -g "$(${cmd.slurp} $SLURP_ARGS)" "tmp.png" && ${cmd.tesseract} "tmp.png" - | ${cmd.wl-copy} && rm "tmp.png"
            ''
            "Ctrl+Super+Shift, Up, movetoworkspacesilent, special"
            "Ctrl+Super+Shift, V, exec, ${cmd.easyeffects}"
            "Ctrl+Super, Slash, exec, ${cmd.pkill} ${cmd.anyrun} || ${cmd.anyrun}"
            "Ctrl+Super, S, togglespecialworkspace, "
            "Ctrl+Super, T, exec, ${cmd."switchwall.sh"}"
            "Ctrl+Super, Up, workspace, r-5"
            "Ctrl+Super, V, exec, ${cmd.pavucontrol}"
            "Super, 0, exec, ${cmd."workspace_action.sh"} 10"
            "Super, 1, exec, ${cmd."workspace_action.sh"} workspace 1"
            "Super, 2, exec, ${cmd."workspace_action.sh"} workspace 2"
            "Super, 3, exec, ${cmd."workspace_action.sh"} workspace 3"
            "Super, 4, exec, ${cmd."workspace_action.sh"} workspace 4"
            "Super, 5, exec, ${cmd."workspace_action.sh"} workspace 5"
            "Super, 6, exec, ${cmd."workspace_action.sh"} workspace 6"
            "Super, 7, exec, ${cmd."workspace_action.sh"} workspace 7"
            "Super, 8, exec, ${cmd."workspace_action.sh"} workspace 8"
            "Super, 9, exec, ${cmd."workspace_action.sh"} workspace 9"
            "Super, A, exec, ${cmd.ags} -t 'sideleft'"
            "Super+Alt, 0, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 10"
            "Super+Alt, 1, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 1"
            "Super+Alt, 2, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 2"
            "Super+Alt, 3, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 3"
            "Super+Alt, 4, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 4"
            "Super+Alt, 5, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 5"
            "Super+Alt, 6, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 6"
            "Super+Alt, 7, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 7"
            "Super+Alt, 8, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 8"
            "Super+Alt, 9, exec, ${cmd."workspace_action.sh"} movetoworkspacesilent 9"
            ''
              Super+Alt, Equal, exec, ${cmd.notify-send} "Urgent notification" "Ah hell no" -u critical -a 'Hyprland keybind'
            ''
            ''
              Super+Alt, f12, exec, ${cmd.notify-send} 'Test notification' "Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a 'Shell' -A "Test1=I got it!" -A "Test2=Another action" -t 5000
            ''
            "Super+Alt, F, fullscreenstate, 0 3"
            "Super+Alt, mouse_down, movetoworkspace, -1"
            "Super+Alt, mouse_up, movetoworkspace, +1"
            "Super+Alt, Page_Down, movetoworkspace, +1"
            "Super+Alt, Page_Up, movetoworkspace, -1"
            "Super+Alt, R, exec, ${cmd."record-script.sh"}"
            "Super+Alt, Slash, exec, ${cmd.pkill} fuzzel || ${cmd.fuzzel}"
            "Super+Alt, S, movetoworkspacesilent, special"
            "Super+Alt, Space, togglefloating, "
            "Super, B, exec, ${cmd.ags} -t 'sideleft'"
            "Super, BracketLeft, movefocus, l"
            "Super, BracketRight, movefocus, r"
            "Super, Comma, exec, ${cmd.ags} run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'"
            "Super, D, fullscreen, 1"
            "Super, Down, movefocus, d"
            ", Super, exec, true"
            "Super, F, fullscreen, 0"
            # ''
            #   Super, I, exec, XDG_CURRENT_DESKTOP="gnome" gnome-control-center
            # ''
            ''
              Super, K, exec, for ((i=0; i<$(hyprctl monitors -j | ${cmd.jq} length); i++)); do ${cmd.ags} -t "osk""$i"; done
            ''
            "Super, Left, movefocus, l"
            "Super, L, exec, loginctl lock-session"
            "Super, M, exec, ${cmd.ags} run-js 'openMusicControls.value = (!mpris.getPlayer() ? false : !openMusicControls.value);'"
            "Super, mouse:275, togglespecialworkspace, "
            "Super, mouse_down, workspace, -1"
            "Super, mouse_up, workspace, +1"
            "Super, N, exec, ${cmd.ags} -t 'sideright'"
            "Super, O, exec, ${cmd.ags} -t 'sideleft'"
            "Super, Page_Down, workspace, +1"
            "Super, Page_Up, workspace, -1"
            # "Super, Period, exec, ${cmd.pkill} fuzzel || ~/.local/bin/fuzzel-emoji"
            "Super, P, pin"
            # "Super, Q, killactive, "
            "Super, Right, movefocus, r"
            "Super+Shift+Alt, mouse:273, exec, ${cmd."primary-buffer-query.sh"}"
            "Super+Shift+Alt, mouse:275, exec, ${cmd.playerctl} previous"
            ''
              Super+Shift+Alt, mouse:276, exec, ${cmd.playerctl} next || ${cmd.playerctl} position `${cmd.bc} <<< "100 * $(${cmd.playerctl} metadata mpris:length) / 1000000 / 100"`
            ''
            "Super+Shift+Alt, Q, exec, ${cmd.hyprctl} kill"
            "Super+Shift+Alt, R, exec, ${cmd."record-script.sh"} --fullscreen-sound"
            ''
              Super+Shift+Alt, S, exec, ${cmd.grim} -g "$(${cmd.slurp})" - | ${pkgs.swappy}/bin/swappy -f -
            ''
            "Super+Shift, C, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a"
            "Super+Shift, Down, movewindow, d"
            "Super+Shift, Left, movewindow, l"
            "Super+Shift, L, exec, loginctl lock-session"
            "Super+Shift, mouse_down, movetoworkspace, r-1"
            "Super+Shift, mouse_up, movetoworkspace, r+1"
            "Super+Shift, Page_Down, movetoworkspace, r+1 "
            "Super+Shift, Page_Up, movetoworkspace, r-1 "
            "Super+Shift, Right, movewindow, r"
            "Super+Shift, S, exec, ${cmd."grimblast.sh"} --freeze copy area"
            ''
              Super+Shift,T,exec, ${cmd.grim} -g "$(${cmd.slurp} $SLURP_ARGS)" "tmp.png" && ${cmd.tesseract} -l eng "tmp.png" - | ${cmd.wl-copy} && rm "tmp.png"
            ''
            "Super+Shift, Up, movewindow, u"
            ''
              Super, Slash, exec, for ((i=0; i<$(${cmd.hyprctl} monitors -j | ${cmd.jq} length); i++)); do ${cmd.ags} -t "cheatsheet""$i"; done
            ''
            "Super, S, togglespecialworkspace, "
            "Super, Tab, exec, ${cmd.ags} -t 'overview'"
            "Super, T, exec, "
            "Super, Up, movefocus, u"
            "Super, V, exec, ${cmd.pkill} fuzzel || ${cmd.cliphist} list | ${cmd.fuzzel}  --match-mode fzf --dmenu | ${cmd.cliphist} decode | ${cmd.wl-copy}"
            "${mainMod}, Q, exec, ${lib.getExe pkgs.kitty}"
            "${mainMod}, E, exec, ${lib.getExe' pkgs.kdePackages.dolphin "dolphin"}"
            "${mainMod}, B, exec, ${lib.getExe pkgs.vivaldi} ${lib.concatStringsSep " " (import ../browser/common.nix).commandLineArgs} --password-store=kwallet6"
            "${mainMod}, C, exec, ${lib.getExe pkgs.vscode-selected}"
            "${mainMod}, W, exec, ${lib.getExe' pkgs.nur.repos.novel2430.wpsoffice-365 "wps"}"
            "ALT, F4, killactive"
            "ALT, Space, exec, ${cmd.pkill} fuzzel || ${lib.getExe pkgs.fuzzel}"
          ];
        bindm = [
          "${mainMod}, mouse:272, movewindow"
          "${mainMod}, mouse:273, resizewindow"
        ];
        bindel =
          let
            wpctl = lib.getExe' pkgs.kdePackages.dolphin "wpctl";
            brightnessctl = lib.getExe pkgs.brightnessctl;
          in
          [
            ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, ${brightnessctl} s 10%+"
            ",XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
          ];
        bindl = [
          ",Print,exec,${cmd.grim} - | ${cmd.wl-copy}"
          "Super+Shift, B, exec, ${cmd.playerctl} previous"
          "Super+Shift, L, exec, ${cmd.sleep} 0.1 && systemctl suspend || loginctl suspend"
          "Super+Shift,M,   exec, ${cmd.ags} run-js 'indicator.popup(1);'"
          "Super+Shift,M, exec, ${cmd.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0%"
          ''
            Super+Shift, N, exec, ${cmd.playerctl} next || ${cmd.playerctl} position `${cmd.bc} <<< "100 * $(${cmd.playerctl} metadata mpris:length) / 1000000 / 100"`
          ''
          "Super+Shift, P, exec, ${cmd.playerctl} play-pause"
          "Super ,XF86AudioMute, exec, ${cmd.wpctl} set-mute @DEFAULT_SOURCE@ toggle"
          ", XF86AudioMute, exec, ${cmd.ags} run-js 'indicator.popup(1);'"
          ",XF86AudioMute, exec, ${cmd.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0%"
          ''
            ,XF86AudioNext, exec, ${cmd.playerctl} next || ${cmd.playerctl} position `bc <<< "100 * $(${cmd.playerctl} metadata mpris:length) / 1000000 / 100"`
          ''
          ",XF86AudioPause, exec, ${cmd.playerctl} play-pause"
          ",XF86AudioPlay, exec, ${cmd.playerctl} play-pause"
          ",XF86AudioPrev, exec, ${cmd.playerctl} previous"
          "Alt ,XF86AudioMute, exec, ${cmd.wpctl} set-mute @DEFAULT_SOURCE@ toggle"
          ''
            Ctrl,Print, exec, mkdir -p ${config.xdg.userDirs.pictures}/Screenshots && ${cmd."grimblast.sh"} copysave screen ${config.xdg.userDirs.pictures}/Screenshots/Screenshot_"$(${cmd.date} '+%Y-%m-%d_%H.%M.%S')".png
          ''
        ];
        bindr = [
          "Ctrl+Super+Alt, R, exec, ${cmd.hyprctl} reload; ${cmd.killall} ags ydotool; ${cmd.ags} &"
          "Ctrl+Super, R, exec, ${cmd.killall} ags ydotool; ${cmd.ags} &"
        ];
        windowrulev2 = [
          "noblur, xwayland:1"
          ''
            float, class:^(blueberry\.py)$
          ''
          "float, class:^(steam)$"
          "float, class:^(guifetch)$"
          "float, class:^(pavucontrol)$"
          "size 45%, class:^(pavucontrol)$"
          "center, class:^(pavucontrol)$"
          "float, class:^(org.pulseaudio.pavucontrol)$"
          "size 45%, class:^(org.pulseaudio.pavucontrol)$"
          "center, class:^(org.pulseaudio.pavucontrol)$"
          "float, class:^(nm-connection-editor)$"
          "size 45%, class:^(nm-connection-editor)$"
          "center, class:^(nm-connection-editor)$"
          ''
            tile, class:^dev\.warp\.Warp$
          ''
          ''
            float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          ''
            keepaspectratio, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          ''
            move 73% 72%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          ''
            size 25%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          ''
            float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          ''
            pin, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
          ''
          "center, title:^(Open File)(.*)$"
          "center, title:^(Select a File)(.*)$"
          "center, title:^(Choose wallpaper)(.*)$"
          "center, title:^(Open Folder)(.*)$"
          "center, title:^(Save As)(.*)$"
          "center, title:^(Library)(.*)$"
          "center, title:^(File Upload)(.*)$"
          "float, title:^(Open File)(.*)$"
          "float, title:^(Select a File)(.*)$"
          "float, title:^(Choose wallpaper)(.*)$"
          "float, title:^(Open Folder)(.*)$"
          "float, title:^(Save As)(.*)$"
          "float, title:^(Library)(.*)$"
          "float, title:^(File Upload)(.*)$"
          ''
            immediate, title:.*\.exe
          ''
          "immediate, class:^(steam_app)"
          "noshadow, floating:0"
        ];
        layerrule = [
          "animation slide left, sideleft.*"
          "animation slide right, sideright.*"
          "blur, bar[0-9]*"
          "blur, barcorner.*"
          "blur, cheatsheet[0-9]*"
          "blur, dock[0-9]*"
          "blur, gtk-layer-shell"
          "blur, indicator.*"
          "blur, indicator.*"
          "blur, launcher"
          "blur, logout_dialog"
          "blur, notifications"
          "blur, osk[0-9]*"
          "blur, overview[0-9]*"
          "blur, session[0-9]*"
          "blur, sideleft[0-9]*"
          "blur, sideright[0-9]*"
          "ignorealpha 0.5, launcher"
          "ignorealpha 0.69, notifications"
          "ignorealpha 0.6, bar[0-9]*"
          "ignorealpha 0.6, barcorner.*"
          "ignorealpha 0.6, cheatsheet[0-9]*"
          "ignorealpha 0.6, dock[0-9]*"
          "ignorealpha 0.6, indicator.*"
          "ignorealpha 0.6, indicator.*"
          "ignorealpha 0.6, osk[0-9]*"
          "ignorealpha 0.6, overview[0-9]*"
          "ignorealpha 0.6, sideleft[0-9]*"
          "ignorealpha 0.6, sideright[0-9]*"
          "ignorezero, gtk-layer-shell"
          "noanim, anyrun"
          "noanim, hyprpicker"
          "noanim, indicator.*"
          "noanim, noanim"
          "noanim, osk"
          "noanim, overview"
          "noanim, selection"
          "noanim, walker"
          "xray 1, .*"
        ];
        workspace = [
          "special:special, gapsout:30"
        ]
        ++ (lib.optionals (hostName == "zawanix-work") [
          "1, monitor:HDMI-A-1, default:true"
          "3, monitor:HDMI-A-1"
          "5, monitor:HDMI-A-1"
          "7, monitor:HDMI-A-1"
          "9, monitor:HDMI-A-1"
          "2, monitor:DP-3, default:true"
          "4, monitor:DP-3"
          "6, monitor:DP-3"
          "8, monitor:DP-3"
          "0, monitor:DP-3"
        ]);
        monitorv2 = (
          lib.optionals (hostName == "zawanix-work") [
            {
              output = "HDMI-A-1";
              mode = "3840x2160@60";
              position = "0x0";
              scale = 2;
              cm = "hdr";
              bitdepth = 10;
              sdr_min_luminance = 0.005;
              sdr_max_luminance = 400;
            }
            {
              output = "DP-3";
              mode = "1920x1080@60";
              position = "1920x0";
              scale = 1;
            }
          ]
        );
        source = [
          "${config.xdg.configHome}/hypr/hyprland/colors.conf"
        ];
        plugin = {
          hyprexpo = {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(000000)";
            workspace_method = "first 1"; # [center/first] [workspace] e.g. first 1 or center m+1
            enable_gesture = false; # laptop touchpad, 4 fingers
            gesture_distance = 300; # how far is the "max"
            gesture_positive = false;
          };
        };
        env =
          (lib.optionals isNvidiaGPU [
            "LIBVA_DRIVER_NAME,nvidia"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "NVD_BACKEND,direct"
            # "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
            "AQ_FORCE_LINEAR_BLIT,0"
          ])
          ++ [
            "NIXOS_OZONE_WL,1"
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
            "QT_QPA_PLATFORM, wayland"
            "QT_QPA_PLATFORMTHEME, qt6ct"
          ];
      };
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "kvantum";
  };
  home.file.".config/Kvantum" = {
    source = pkgs.illogical-impulse.kvantum;
    recursive = true;
  };
}
