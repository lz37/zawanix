local opt = require("option")
local hw = opt.hardware

-- Static env vars
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("GDK_SCALE", "1")
hl.env("XCURSOR_SIZE", "32")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("SDL_VIDEODRIVER", "x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("EDITOR", "code --wait")
hl.env("TERMINAL", "kitty")
hl.env("XDG_TERMINAL_EMULATOR", "kitty")

-- AQ_DRM_DEVICES (conditional on hardware-specific DRM path)
if hw.drm.aqDrmDevices ~= "" then
    hl.env("AQ_DRM_DEVICES", hw.drm.aqDrmDevices)
end

-- Nvidia-specific vars
if hw.isNvidiaGPU then
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")

    -- AQ_FORCE_LINEAR_BLIT=0 for Nvidia + AMD/Intel hybrid graphics
    if hw.isAmdGPU or hw.isIntelGPU then
        hl.env("AQ_FORCE_LINEAR_BLIT", "0")
    end
end

-- LIBVA_DRIVER_NAME for Nvidia dGPU path
if hw.isNvidiaGPU and hw.drm.aqDrmDevices ~= "" and hw.drm.aqDrmDevices:find("/dev/dri/dgpu") then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
end
