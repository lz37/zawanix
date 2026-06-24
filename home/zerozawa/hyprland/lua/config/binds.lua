local hs = require("hyprsplit")

local exec = hl.dsp.exec_cmd
local focus = hl.dsp.focus
local window = hl.dsp.window
local workspace = hl.dsp.workspace

local terminal = "kitty"
local browser = table.concat({
    "vivaldi",
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL",
    "--disable-features=UseChromeOSDirectVideoDecoder",
    "--ozone-platform-hint=auto",
    "--enable-wayland-ime",
    "--wayland-text-input-version=3",
    "--force-device-scale-factor",
    "--password-store=kwallet6",
}, " ")
local browser_debug = browser .. " --remote-debugging-port=9222"

-- Terminal
hl.bind("SUPER + Return", exec(terminal))

-- DMS IPC
hl.bind("SUPER + Tab", exec("dms ipc call hypr toggleOverview"))
hl.bind("SUPER + SHIFT + Return", exec("dms ipc call spotlight toggle"))
hl.bind("SUPER + V", exec("dms ipc call clipboard toggle"))
hl.bind("SUPER + M", exec("dms ipc call processlist toggle"))
hl.bind("SUPER + N", exec("dms ipc call notifications toggle"))
hl.bind("SUPER + comma", exec("dms ipc call settings toggle"))
hl.bind("SUPER + P", exec("dms ipc call notepad toggle"))
hl.bind("SUPER + ALT + L", exec("dms ipc call lock lock"))
hl.bind("SUPER + X", exec("dms ipc plugins toggle fullscreenPowerMenu"))
hl.bind("SUPER + SHIFT + X", exec("dms ipc call powermenu toggle"))
hl.bind("SUPER + C", exec("dms ipc call control-center toggle"))
hl.bind("SUPER + A", exec("dms ipc plugins toggle aiAssistant"))

-- Audio and brightness keys
hl.bind("XF86AudioRaiseVolume", exec("dms ipc call audio increment 3"))
hl.bind("XF86AudioLowerVolume", exec("dms ipc call audio decrement 3"))
hl.bind("XF86AudioMute", exec("dms ipc call audio mute"))
hl.bind("XF86AudioMicMute", exec("dms ipc call audio micmute"))
hl.bind("XF86MonBrightnessUp", exec("dms ipc call brightness increment 5 \"\""))
hl.bind("XF86MonBrightnessDown", exec("dms ipc call brightness decrement 5 \"\""))

-- DMS and pypr toggles
hl.bind("SUPER + SHIFT + N", exec("dms ipc call night toggle"))
hl.bind("SUPER + SHIFT + T", exec("pypr toggle term"))

-- Applications
hl.bind("SUPER + W", exec(browser))
hl.bind("SUPER + SHIFT + W", exec(browser_debug))
hl.bind("SUPER + Y", exec("kitty -e yazi"))
hl.bind("SUPER + S", exec("screenshootin"))
hl.bind("Print", exec("screenshootin"))
hl.bind("SUPER + O", exec("obs"))
hl.bind("SUPER + G", exec("gimp"))
hl.bind("SUPER + T", exec("dolphin"))
hl.bind("SUPER + SHIFT + V", exec("code"))

-- Media controls
hl.bind("XF86AudioPlay", exec("playerctl play-pause"))
hl.bind("XF86AudioPause", exec("playerctl play-pause"))
hl.bind("XF86AudioNext", exec("playerctl next"))
hl.bind("XF86AudioPrev", exec("playerctl previous"))

-- Window operations
hl.bind("SUPER + Q", window.close())
hl.bind("SUPER + F", window.fullscreen())
hl.bind("SUPER + SHIFT + F", window.float())
hl.bind("SUPER + CONTROL + F", window.fullscreen_state({ internal = 0, client = 3 }))
hl.bind("SUPER + ALT + F", exec("hyprctl dispatch workspaceopt allfloat"))

-- Move focus with arrows and HJKL
hl.bind("SUPER + left", focus({ direction = "left" }))
hl.bind("SUPER + right", focus({ direction = "right" }))
hl.bind("SUPER + up", focus({ direction = "up" }))
hl.bind("SUPER + down", focus({ direction = "down" }))
hl.bind("SUPER + H", focus({ direction = "left" }))
hl.bind("SUPER + L", focus({ direction = "right" }))
hl.bind("SUPER + K", focus({ direction = "up" }))
hl.bind("SUPER + J", focus({ direction = "down" }))

-- Move windows with arrows and HJKL
hl.bind("SUPER + SHIFT + left", window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + H", window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K", window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", window.move({ direction = "down" }))

-- Swap windows with arrows and HJKL
hl.bind("SUPER + ALT + left", window.swap({ direction = "left" }))
hl.bind("SUPER + ALT + right", window.swap({ direction = "right" }))
hl.bind("SUPER + ALT + up", window.swap({ direction = "up" }))
hl.bind("SUPER + ALT + down", window.swap({ direction = "down" }))
hl.bind("SUPER + ALT + code:43", window.swap({ direction = "left" }))
hl.bind("SUPER + ALT + code:46", window.swap({ direction = "right" }))
hl.bind("SUPER + ALT + code:45", window.swap({ direction = "up" }))
hl.bind("SUPER + ALT + code:44", window.swap({ direction = "down" }))

-- Special workspace
hl.bind("SUPER + SHIFT + SPACE", window.move({ workspace = "special" }))
hl.bind("SUPER + SPACE", workspace.toggle_special())

-- Alt-tab cycle and raise
hl.bind("ALT + Tab", window.cycle_next())
hl.bind("ALT + Tab", window.bring_to_top())

-- Hyprsplit: per-monitor workspace switching
hl.bind("SUPER + 1", hs.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hs.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3", hs.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4", hs.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hs.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hs.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hs.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hs.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hs.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hs.dsp.focus({ workspace = 10 }))

-- Hyprsplit: move active window to per-monitor workspace
hl.bind("SUPER + SHIFT + 1", hs.dsp.window.move({ workspace = 1, follow = false }))
hl.bind("SUPER + SHIFT + 2", hs.dsp.window.move({ workspace = 2, follow = false }))
hl.bind("SUPER + SHIFT + 3", hs.dsp.window.move({ workspace = 3, follow = false }))
hl.bind("SUPER + SHIFT + 4", hs.dsp.window.move({ workspace = 4, follow = false }))
hl.bind("SUPER + SHIFT + 5", hs.dsp.window.move({ workspace = 5, follow = false }))
hl.bind("SUPER + SHIFT + 6", hs.dsp.window.move({ workspace = 6, follow = false }))
hl.bind("SUPER + SHIFT + 7", hs.dsp.window.move({ workspace = 7, follow = false }))
hl.bind("SUPER + SHIFT + 8", hs.dsp.window.move({ workspace = 8, follow = false }))
hl.bind("SUPER + SHIFT + 9", hs.dsp.window.move({ workspace = 9, follow = false }))
hl.bind("SUPER + SHIFT + 0", hs.dsp.window.move({ workspace = 10, follow = false }))

-- Hyprsplit: workspace navigation and monitor helpers
hl.bind("SUPER + CONTROL + right", hs.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + CONTROL + left", hs.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_down", hs.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hs.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + S", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
hl.bind("SUPER + SHIFT + G", hs.dsp.grab_rogue_windows())

-- Mouse drag/resize binds
hl.bind("SUPER + mouse:272", window.drag(), { mouse = true })
hl.bind("SUPER + Control_L", window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", window.resize(), { mouse = true })
hl.bind("SUPER + ALT_L", window.resize(), { mouse = true })

-- Gestures
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace",
})
hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        hl.exec_cmd("dms ipc call hypr closeOverview")
    end,
})
hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
        hl.exec_cmd("dms ipc call hypr openOverview")
    end,
})
hl.gesture({
    fingers = 3,
    direction = "down",
    mods = "ALT",
    action = "close",
})
hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.exec_cmd("pypr show term")
    end,
})
hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.exec_cmd("pypr hide term")
    end,
})
hl.gesture({
    fingers = 3,
    direction = "pinchin",
    action = function()
        hl.dispatch(window.fullscreen({ mode = "fullscreen", action = "set" }))
    end,
})
hl.gesture({
    fingers = 3,
    direction = "pinchout",
    action = function()
        hl.dispatch(window.fullscreen({ mode = "fullscreen", action = "unset" }))
    end,
})
