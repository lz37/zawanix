local home = os.getenv("HOME")

-- Temporarily disabled: the packaged plugin is incompatible with Hyprland 0.56.2.
-- hl.plugin.load(home .. "/.config/hypr/plugins/hypr-dynamic-cursors.so")
hl.plugin.load(home .. "/.config/hypr/plugins/hyprfocus.so")

hl.config({
    plugin = {
        hyprfocus = {
            keyboard_focus_animation = "flash",
            mouse_focus_animation = "flash",
            only_on_monitor_change = false,
            fade_opacity = 0.9,
        },
        -- dynamic_cursors = {
        --     enabled = true,
        --     mode = "none",
        --     shake = {
        --         enabled = true,
        --         threshold = 6.0,
        --         base = 4.0,
        --         speed = 4.0,
        --         influence = 0.0,
        --         limit = 0.0,
        --         timeout = 2000,
        --         effects = false,
        --         ipc = false,
        --     },
        --     hyprcursor = {
        --         nearest = true,
        --         enabled = true,
        --         resolution = -1,
        --         fallback = "clientside",
        --     },
        -- },
    },
})
