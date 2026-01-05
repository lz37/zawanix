{...}: let
  to_legacyRule = rule:
    if builtins.typeOf rule == "string"
    then rule
    else let
      serializeMatch = _match: let
        serializePair = key: value:
          if builtins.typeOf value == "bool"
          then "match:${key} ${
            if value
            then "1"
            else "0"
          }"
          else "match:${key} ${value}";
      in
        builtins.concatStringsSep ", " (
          builtins.filter (x: x != "") (
            map (k: serializePair k (_match.${k})) (builtins.attrNames _match)
          )
        );
      serializeAction = action: let
        serializePair = key: value: "${key} ${
          if builtins.typeOf value == "bool"
          then
            (
              if value
              then "1"
              else "0"
            )
          else value
        }";
      in
        builtins.concatStringsSep ", " (
          map (k: serializePair k (action.${k})) (builtins.attrNames action)
        );
    in "${serializeMatch rule.match}, ${serializeAction (removeAttrs rule ["match"])}";
  to_legacyRules = rules:
    map to_legacyRule rules;
in {
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = to_legacyRules [
        {
          match = {xwayland = true;};
          no_blur = true;
        } # Helps prevent odd borders/shadows for xwayland apps
        # downside it can impact other xwayland apps
        # This rule is a template for a more targeted approach
        {
          match = {
            xwayland = true;
            class = "^(\\bresolve\\b)$";
          };
          no_blur = true;
        } # Window rule for just resolve
        "tag +file-manager, match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, match:class ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
        "tag +browser, match:class ^(Brave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Tt]horium-browser|[Cc]achy-browser)$"
        "tag +projects, match:class ^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, match:class ^(VSCode|code-url-handler)$"
        "tag +im, match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, match:class ^([Ff]erdium)$"
        "tag +im, match:class ^([Ww]hatsapp-for-linux)$"
        "tag +im, match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, match:class ^(teams-for-linux)$"
        "tag +games, match:class ^(gamescope)$"
        "tag +games, match:class ^(steam_app_\\d+)$"
        "tag +gamestore, match:class ^([Ss]team)$"
        "tag +gamestore, match:title ^([Ll]utris)$"
        "tag +gamestore, match:class ^(com.heroicgameslauncher.hgl)$"
        "tag +settings, match:class ^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, match:class ^([Rr]ofi)$"
        "tag +settings, match:class ^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, match:class ^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "tag +settings, match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, match:class (xdg-desktop-portal-gtk)"
        "tag +settings, match:class (.blueman-manager-wrapped)"
        "tag +settings, match:class (nwg-displays)"
        {
          match = {
            title = "^(Picture-in-Picture)$";
          };
          move = "72% 7%";
          float = true;
          opacity = "0.95 0.75";
          pin = true;
          keep_aspect_ratio = true;
        }
        {
          match = {
            class = "^([Ff]erdium)$";
          };
          center = true;
        }
        {
          match = {
            class = "^([Ww]aypaper)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";
          };
          center = true;
        }
        {
          match = {
            class = "([Tt]hunar)";
            title = "negative:(.*[Tt]hunar.*)";
          };
          center = true;
        }
        {
          match = {
            title = "^(Authentication Required)$";
          };
          center = true;
        }
        {
          match = {
            class = "^(*)$";
          };
          idle_inhibit = "fullscreen";
        }
        {
          match = {
            title = "^(*)$";
          };
          idle_inhibit = "fullscreen";
        }
        {
          match = {
            fullscreen = true;
          };
          idle_inhibit = "fullscreen";
        }
        {
          match = {
            tag = "settings*";
          };
          float = true;
          size = "70% 70%";
          opacity = "0.8 0.7";
        }
        {
          match = {
            class = "^([Ff]erdium)$";
          };
          float = true;
          size = "60% 70%";
        }
        {
          match = {
            class = "^(mpv|com.github.rafostar.Clapper)$";
          };
          float = true;
        }
        {
          match = {
            title = "^(Authentication Required)$";
          };
          float = true;
        }
        {
          match = {
            class = "(codium|codium-url-handler|VSCodium)";
            title = "negative:(.*codium.*|.*VSCodium.*)";
          };
          float = true;
        }
        {
          match = {
            class = "^(com.heroicgameslauncher.hgl)$";
            title = "negative:(Heroic Games Launcher)";
          };
          float = true;
        }
        {
          match = {
            class = "^([Ss]team)$";
            title = "negative:^([Ss]team)$";
          };
          float = true;
        }
        {
          match = {
            class = "([Tt]hunar)";
            title = "negative:(.*[Tt]hunar.*)";
          };
          float = true;
        }
        {
          match = {
            initial_title = "(Add Folder to Workspace)";
          };
          float = true;
          size = "70% 60%";
        }
        {
          match = {
            initial_title = "(Open Files)";
          };
          float = true;
          size = "70% 60%";
        }
        {
          match = {
            initial_title = "(wants to save)";
          };
          float = true;
        }
        {
          match = {
            tag = "browser*";
          };
          opacity = "1.0 1.0";
        }
        {
          match = {
            tag = "projects*";
          };
          opacity = "0.9 0.8";
        }
        {
          match = {
            tag = "im*";
          };
          opacity = "0.94 0.86";
        }
        {
          match = {
            tag = "file-manager*";
          };
          opacity = "0.9 0.8";
        }
        {
          match = {
            tag = "terminal*";
          };
          opacity = "0.8 0.7";
        }
        {
          match = {
            class = "^(gedit|org.gnome.TextEditor|mousepad)$";
          };
          opacity = "0.8 0.7";
        }
        {
          match = {
            class = "^(seahorse)$";
          };
          opacity = "0.9 0.8";
        } # gnome-keyring gui
        {
          match = {
            class = "^(mpv|com.github.rafostar.Clapper)$";
          };
          opacity = "1.0 1.0";
        }
        {
          match = {
            tag = "games*";
          };
          no_blur = true;
          fullscreen = true;
        }
        {
          match = {
            class = "Waydroid";
          };
          fullscreen = true;
        }
        {
          match = {
            class = "^([Vv]ivaldi ((Settings)|(设置)).*))$";
          };
          float = true;
        }
        {
          match = {
            class = "wechat";
          };
          float = true;
        }
        {
          match = {
            class = "QQ";
          };
          float = true;
        }
        {
          match = {
            title = "^(DevTools.*)$";
            initial_class = "^((code)|(chromium-browser))$";
          };
          float = true;
        }
        {
          match = {
            class = "^(xwaylandvideobridge)$";
          };
          opacity = "0.0 override";
          size = "0% 0%";
        }
        {
          match = {
            class = "kitty-dropterm";
          };
          float = true;
        }
      ];
    };
  };
}
