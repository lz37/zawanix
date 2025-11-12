{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font = {
      # package = pkgs.meslo-lgs-nf;
      # name = "MesloLGS NF";
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font Mono";
    };
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    # themeFile = "Monokai_Soda";
    settings = {
      shell = lib.getExe pkgs.zsh;
      # Font settings
      font_size = "12.0";
      disable_ligatures = "never";

      # Cursor settings
      cursor = "#cccccc";
      cursor_text_color = "#111111";
      cursor_shape = "block";
      cursor_shape_unfocused = "hollow";
      cursor_beam_thickness = "1.5";
      cursor_underline_thickness = "2.0";
      cursor_blink_interval = "-1";
      cursor_stop_blinking_after = "15.0";
      cursor_trail = "100";
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = "2";

      # Scrollback settings
      scrollback_lines = "4000";
      scrollbar = "never";
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
      scrollback_pager_history_size = "0";
      scrollback_fill_enlarged_window = "no";
      wheel_scroll_multiplier = "5.0";
      wheel_scroll_min_lines = "1";
      touch_scroll_multiplier = "1.0";

      # Mouse settings
      mouse_hide_wait = "3.0";
      url_color = "#0087bd";
      url_style = "curly";
      open_url_with = "default";
      detect_urls = "yes";
      show_hyperlink_targets = "yes";
      underline_hyperlinks = "hover";
      copy_on_select = "no";
      paste_actions = "quote-urls-at-prompt,confirm";

      # Performance settings
      sync_to_monitor = "yes";

      # Bell settings
      enable_audio_bell = "yes";
      window_alert_on_bell = "yes";
      bell_on_tab = "🔔 ";

      # Window layout settings
      active_border_color = "#00ff00";
      inactive_border_color = "#cccccc";
      bell_border_color = "#ff5a00";
      inactive_text_alpha = "1.0";
      hide_window_decorations = "no";
      confirm_os_window_close = "0";

      # Color scheme settings
      background_opacity = "0.6";

      window_padding_width = 4;
      tab_fade = 1;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";
      tab_bar_edge = "top";
      tab_bar_margin_width = 0;
      tab_bar_style = "powerline";
      # tab_bar_style = "fade";
      enabled_layouts = "splits";
    };

    # Mouse mappings
    extraConfig = ''
      include ${config.xdg.configHome}/kitty/dank-theme.conf
      # Mouse mappings
      mouse_map middle release ungrabbed paste_from_selection
      mouse_map left press ungrabbed mouse_selection normal
      mouse_map ctrl+alt+left press ungrabbed mouse_selection rectangle
      mouse_map left doublepress ungrabbed mouse_selection word
      mouse_map left triplepress ungrabbed mouse_selection line
      mouse_map ctrl+alt+left triplepress ungrabbed mouse_selection line_from_point
      mouse_map right press ungrabbed mouse_selection extend
      mouse_map shift+middle release ungrabbed,grabbed paste_selection
      mouse_map shift+middle press grabbed discard_event
      mouse_map shift+left press ungrabbed,grabbed mouse_selection normal
      mouse_map ctrl+shift+alt+left press ungrabbed,grabbed mouse_selection rectangle
      mouse_map shift+left doublepress ungrabbed,grabbed mouse_selection word
      mouse_map shift+left triplepress ungrabbed,grabbed mouse_selection line
      mouse_map ctrl+shift+alt+left triplepress ungrabbed,grabbed mouse_selection line_from_point
      mouse_map shift+right press ungrabbed,grabbed mouse_selection extend
      mouse_map ctrl+shift+right press ungrabbed mouse_show_command_output

      # Clipboard
      map ctrl+shift+v        paste_from_selection
      map shift+insert        paste_from_selection

      # Scrolling
      map ctrl+shift+up        scroll_line_up
      map ctrl+shift+down      scroll_line_down
      map ctrl+shift+k         scroll_line_up
      map ctrl+shift+j         scroll_line_down
      map ctrl+shift+page_up   scroll_page_up
      map ctrl+shift+page_down scroll_page_down
      map ctrl+shift+home      scroll_home
      map ctrl+shift+end       scroll_end
      map ctrl+shift+h         show_scrollback

      # Window management
      map alt+n               new_window_with_cwd       #open in current dir
      #map alt+n              new_os_window             #opens term in $HOME
      map alt+w               close_window
      map ctrl+shift+enter    launch --location=hsplit
      map ctrl+shift+s        launch --location=vsplit
      map ctrl+shift+]        next_window
      map ctrl+shift+[        previous_window
      map ctrl+shift+f        move_window_forward
      map ctrl+shift+b        move_window_backward
      map ctrl+shift+`        move_window_to_top
      map ctrl+shift+1        first_window
      map ctrl+shift+2        second_window
      map ctrl+shift+3        third_window
      map ctrl+shift+4        fourth_window
      map ctrl+shift+5        fifth_window
      map ctrl+shift+6        sixth_window
      map ctrl+shift+7        seventh_window
      map ctrl+shift+8        eighth_window
      map ctrl+shift+9        ninth_window # Tab management
      map ctrl+shift+0        tenth_window
      map ctrl+shift+right    next_tab
      map ctrl+shift+left     previous_tab
      map ctrl+shift+t        new_tab
      map ctrl+shift+q        close_tab
      map ctrl+shift+l        next_layout
      map ctrl+shift+.        move_tab_forward
      map ctrl+shift+,        move_tab_backward

      # Miscellaneous
      map ctrl+shift+up      increase_font_size
      map ctrl+shift+down    decrease_font_size
      map ctrl+shift+backspace restore_font_size

    '';
  };
}
