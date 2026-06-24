local home = os.getenv("HOME")

hl.plugin.load(home .. "/.config/hypr/plugins/hypr-dynamic-cursors.so")
hl.plugin.load(home .. "/.config/hypr/plugins/hyprfocus.so")

hl.config({
    plugin = {
        hyprfocus = {
            mode = "shrink",
            only_on_monitor_change = false,
        },
        dynamic_cursors = {
            enabled = true,
            mode = "none",
            shake = {
                enabled = true,
                threshold = 6.0,
                base = 4.0,
                speed = 4.0,
                influence = 0.0,
                limit = 0.0,
                timeout = 2000,
                effects = false,
                ipc = false,
            },
            hyprcursor = {
                nearest = true,
                enabled = true,
                resolution = -1,
                fallback = "clientside",
            },
        },
    },
})
