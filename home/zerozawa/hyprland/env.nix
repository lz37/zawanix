{
  lib,
  osConfig,
  ...
}: let
  hw = osConfig.zerozawa.hardware;
  aqDrmDevices = osConfig.zerozawa.hardware.drm.aqDrmDevices;
in {
  wayland.windowManager.hyprland = {
    settings = {
      env =
        [
          "QT_QPA_PLATFORMTHEME, qt6ct"
          "QT_QPA_PLATFORMTHEME_QT6, qt6ct"
          "NIXOS_OZONE_WL, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
          # This is to make electron apps start in wayland
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "EDITOR,code --wait"
          # Set terminal and xdg_terminal_emulator to kitty
          # To provent yazi from starting xterm when run from rofi menu
          # You can set to your preferred terminal if you you like
          # ToDo: Pull default terminal from config
          "TERMINAL,kitty"
          "XDG_TERMINAL_EMULATOR,kitty"
        ]
        ++ (lib.optionals (aqDrmDevices != "") [
          "AQ_DRM_DEVICES,${aqDrmDevices}"
        ])
        ++ (lib.optionals (hw.isNvidiaGPU && lib.hasPrefix "/dev/dri/dgpu" aqDrmDevices) [
          "LIBVA_DRIVER_NAME,nvidia"
        ])
        ++ (lib.optionals hw.isNvidiaGPU [
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "NVD_BACKEND,direct"
          # "__NV_PRIME_RENDER_OFFLOAD,1"
          # "GBM_BACKEND,nvidia-drm"
          # "WLR_NO_HARDWARE_CURSORS,1"
          # 修复 EGL 崩溃问题
          # "AQ_FORCE_LINEAR_BLIT,1" # 设为0副屏会卡但兼容会好
          # 强制使用 NVIDIA EGL
          # "EGL_PLATFORM,wayland"
        ])
        ++ (lib.optionals (hw.isNvidiaGPU && (hw.isAmdGPU || hw.isIntelGPU)) [
          "AQ_FORCE_LINEAR_BLIT=0"
        ]);
    };
  };
}
