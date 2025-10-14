{
  pkgs,
  isNvidiaGPU,
  hostName,
  config,
  lib,
  ...
}: let
  inherit (pkgs) anime4k;
  renderOption = option:
    rec {
      int = toString option;
      float = int;
      bool = lib.hm.booleans.yesNo option;
      string = option;
    }
    .${
      builtins.typeOf option
    };
  renderOptionValue = value: let
    rendered = renderOption value;
    length = toString (builtins.stringLength rendered);
  in "%${length}%${rendered}";
  renderOptions = lib.generators.toKeyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault {mkValueString = renderOptionValue;} "=";
    listsAsDuplicateKeys = true;
  };
  renderProfiles = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault {mkValueString = renderOptionValue;} "=";
    listsAsDuplicateKeys = true;
  };
  renderDefaultProfiles = profiles: renderOptions {profile = lib.concatStringsSep "," profiles;};
  mpv-common = {
    config = let
      yes = "yes";
      no = "no";
    in {
      # https://hooke007.github.io/index.html
      input-ipc-server = "/tmp/mpvsocket";
      autoload-files = yes;
      target-colorspace-hint = yes;
      osc = no;
      border = no;
      # svp
      hwdec = "auto-copy";
      hwdec-codecs = "all";
      hr-seek-framedrop = no;
      cache = yes;
      # svp
      demuxer-max-bytes = "128MiB";
      cache-on-disk = no;
      cache-secs = 8;
      # icc-profile-auto = yes;
      # video-sync = "display-resample";
      # interpolation = yes;
      # vf-append = "format=gamma=gamma2.2";
      # icc-cache-dir = "~~/icc_cache";
      # gpu-shader-cache-dir = "~~/shaders_cache";
      # audio-file-auto = "fuzzy";
      # audio-pitch-correction = yes;
      # audio-exclusive = no;
      # audio-device = "auto";
      volume = 100;
      volume-max = 200;
      glsl-shaders =
        if isNvidiaGPU
        then "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
        else "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl";
    };
    defaultProfiles = ["gpu-hq"];
    profiles = {};
  };
in {
  stylix.targets.mpv.enable = true;
  xdg.configFile = let
    mpv-scripts = pkgs.buildEnv {
      name = "mpv-scripts";
      paths = with pkgs.mpvScripts; [
        mpris
        modernx
        memo
        mpv-notify-send
        thumbfast
      ];
    };
  in {
    "mpv/scripts".source = "${mpv-scripts}/share/mpv/scripts";
    "mpv/fonts".source = "${mpv-scripts}/share/fonts";
    "jellyfin-mpv-shim/fonts".source = "${mpv-scripts}/share/fonts";
    "jellyfin-mpv-shim/scripts".source = "${mpv-scripts}/share/mpv/scripts";
    "jellyfin-mpv-shim/mpv.conf".text = ''
      ${lib.optionalString (mpv-common.defaultProfiles != []) (renderDefaultProfiles mpv-common.defaultProfiles)}
      ${lib.optionalString (mpv-common.config != {}) (renderOptions mpv-common.config)}
      ${lib.optionalString (mpv-common.profiles != {}) (renderProfiles mpv-common.profiles)}
    '';
    "jellyfin-mpv-shim/script-opts".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/script-opts";
    "jellyfin-mpv-shim/input.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/input.conf";
    "jellyfin-mpv-shim/conf.json".source = pkgs.stdenv.mkDerivation {
      src = (pkgs.formats.json {}).generate "jellyfin-mpv-shim.config.json" {
        "allow_transcode_to_h265" = false;
        "always_transcode" = false;
        "audio_output" = "hdmi";
        "auto_play" = true;
        "check_updates" = false;
        "client_uuid" = "";
        "connect_retry_mins" = 0;
        "direct_paths" = false;
        "discord_presence" = false;
        "display_mirroring" = false;
        "enable_gui" = true;
        "enable_osc" = true;
        "force_audio_codec" = null;
        "force_set_played" = false;
        "force_video_codec" = null;
        "fullscreen" = true;
        "health_check_interval" = 300;
        "idle_cmd" = null;
        "idle_cmd_delay" = 60;
        "idle_ended_cmd" = null;
        "idle_when_paused" = false;
        "ignore_ssl_cert" = false;
        "kb_debug" = "~";
        "kb_fullscreen" = "f";
        "kb_kill_shader" = "k";
        "kb_menu" = "c";
        "kb_menu_down" = "down";
        "kb_menu_esc" = "esc";
        "kb_menu_left" = "left";
        "kb_menu_ok" = "enter";
        "kb_menu_right" = "right";
        "kb_menu_up" = "up";
        "kb_next" = ">";
        "kb_pause" = "space";
        "kb_prev" = "<";
        "kb_stop" = "q";
        "kb_unwatched" = "u";
        "kb_watched" = "w";
        "lang" = null;
        "lang_filter" = "und;eng;jpn;mis;mul;zxx";
        "lang_filter_audio" = false;
        "lang_filter_sub" = false;
        "local_kbps" = 2147483;
        "log_decisions" = false;
        "media_ended_cmd" = null;
        "media_key_seek" = false;
        "media_keys" = true;
        "menu_mouse" = true;
        "mpv_ext" = true;
        "mpv_ext_ipc" = null;
        "mpv_ext_no_ovr" = false;
        "mpv_ext_path" = lib.getExe pkgs.mpv;
        "mpv_ext_start" = true;
        "mpv_log_level" = "info";
        "notify_updates" = false;
        "play_cmd" = null;
        "playback_timeout" = 30;
        "player_name" = "zawanix-glap";
        "pre_media_cmd" = null;
        "prefer_transcode_to_h265" = false;
        "raise_mpv" = true;
        "remote_direct_paths" = false;
        "remote_kbps" = 20000;
        "sanitize_output" = true;
        "screenshot_dir" = null;
        "screenshot_menu" = true;
        "seek_down" = -60;
        "seek_h_exact" = false;
        "seek_left" = -5;
        "seek_right" = 5;
        "seek_up" = 60;
        "seek_v_exact" = false;
        "shader_pack_custom" = false;
        "shader_pack_enable" = false;
        "shader_pack_profile" = "anime4k-fast-ca";
        "shader_pack_remember" = true;
        "shader_pack_subtype" = "lq";
        "skip_credits_always" = false;
        "skip_credits_enable" = true;
        "skip_intro_always" = false;
        "skip_intro_enable" = true;
        "stop_cmd" = null;
        "stop_idle" = false;
        "subtitle_color" = "#FFFFFFFF";
        "subtitle_position" = "bottom";
        "subtitle_size" = 100;
        "svp_enable" = false;
        "svp_socket" = null;
        "svp_url" = "http://127.0.0.1:9901/";
        "sync_attempts" = 5;
        "sync_max_delay_skip" = 300;
        "sync_max_delay_speed" = 50;
        "sync_method_thresh" = 2000;
        "sync_osd_message" = true;
        "sync_revert_seek" = true;
        "sync_speed_attempts" = 3;
        "sync_speed_time" = 1000;
        "thumbnail_enable" = true;
        "thumbnail_osc_builtin" = true;
        "thumbnail_preferred_size" = 320;
        "tls_client_cert" = null;
        "tls_client_key" = null;
        "tls_server_ca" = null;
        "transcode_4k" = false;
        "transcode_av1" = false;
        "transcode_dolby_vision" = true;
        "transcode_hdr" = false;
        "transcode_hevc" = false;
        "transcode_hi10p" = false;
        "transcode_warning" = true;
        "use_web_seek" = false;
        "write_logs" = false;
      };
      name = "jellyfin-mpv-shim-config-json";
      dontUnpack = true;
      buildInputs = with pkgs; [jq util-linux];
      buildPhase = ''
        runHook preBuild
        UUID=$(uuidgen --namespac @dns --name ${hostName} --md5)
        jq --arg uuid "$UUID" '.client_uuid = $uuid' $src > $out
        runHook postBuild
      '';
    };
  };
  home = {
    packages = with pkgs; [
      jellyfin-mpv-shim
      svp
      vapoursynth
    ];
  };
  programs.mpv = {
    inherit (mpv-common) defaultProfiles profiles;
    enable = true;
    package = pkgs.mpv;
    config =
      mpv-common.config
      // {
        vo = "gpu-next";
        gpu-api = "vulkan";
        gpu-context = "waylandvk";
      };
    bindings =
      if isNvidiaGPU
      then {
        "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';
        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
      }
      else {
        "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
      };
  };
}
