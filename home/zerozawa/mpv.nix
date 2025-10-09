{pkgs, ...}: {
  stylix.targets.mpv.enable = true;
  home.packages = with pkgs; [
    jellyfin-mpv-shim
  ];
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      modernx
      memo
      mpv-notify-send
    ];
    config = {
      autoload-files = "yes";
      profile = "high-quality";
      vo = "gpu-next";
      target-colorspace-hint = "yes";
      gpu-api = "vulkan";
      gpu-context = "waylandvk";
    };
    bindings = let
      inherit (pkgs) anime4k;
    in {
      "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Restore_CNN_VL.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
      "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
      "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
      "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Restore_CNN_VL.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Restore_CNN_M.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
      "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
      "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl;${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl;${anime4k}/Anime4K_AutoDownscalePre_x2.glsl;${anime4k}/Anime4K_AutoDownscalePre_x4.glsl;${anime4k}/Anime4K_Restore_CNN_M.glsl;${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';

      "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
    };
  };
}
