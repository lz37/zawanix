{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}: let
  inherit (pkgs) anime4k;
  hw = osConfig.zerozawa.hardware;
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
      hwdec = "auto-copy";
      hwdec-codecs = "all";
      hr-seek-framedrop = no;
      cache = yes;
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
        if hw.isNvidiaGPU
        then "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
        else "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl";
    };
    defaultProfiles = ["gpu-hq"];
    profiles = {};
  };
in {
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
    mpv-scripts-for-jellyfin-mpv-shim = pkgs.buildEnv {
      name = "mpv-scripts-for-jellyfin-mpv-shim";
      paths = with pkgs.mpvScripts; [
        mpris
        mpv-notify-send
        thumbfast
      ];
    };
  in {
    "mpv/scripts".source = "${mpv-scripts}/share/mpv/scripts";
    "mpv/fonts".source = "${mpv-scripts}/share/fonts/truetype";
    "jellyfin-mpv-shim/scripts".source = "${mpv-scripts-for-jellyfin-mpv-shim}/share/mpv/scripts";
    "jellyfin-mpv-shim/mpv.conf".text = ''
      ${lib.optionalString (mpv-common.defaultProfiles != []) (
        renderDefaultProfiles mpv-common.defaultProfiles
      )}
      ${lib.optionalString (mpv-common.config != {}) (renderOptions mpv-common.config)}
      ${lib.optionalString (mpv-common.profiles != {}) (renderProfiles mpv-common.profiles)}
    '';
    "jellyfin-mpv-shim/script-opts".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/script-opts";
    "jellyfin-mpv-shim/input.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/input.conf";
  };
  home = {
    packages = with pkgs; [
      jellyfin-mpv-shim
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
      if hw.isNvidiaGPU
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
