-- Main Hyprland Lua entry point.
-- Keep require() rooted at the deployed config directory so both hand-written
-- modules and DMS-generated modules resolve the same way at runtime.
local home = os.getenv("HOME")
if not home or home == "" then
    error("HOME is not set; cannot locate ~/.config/hypr", 0)
end
local hypr_dir = home .. "/.config/hypr"
local lux_dir = hypr_dir .. "/lux_packages"
package.path = hypr_dir .. "/?.lua;"
    .. hypr_dir .. "/?/init.lua;"
    .. lux_dir .. "/?.lua;"
    .. lux_dir .. "/?/init.lua;"
    .. package.path

-- Clear require cache so hyprctl reload picks up file changes
for k in pairs(package.loaded) do
    if k:match("^config%.") then
        package.loaded[k] = nil
    end
end

-- Load the Nix bridge before any host-conditioned config modules.
local opt = require("option")

require("config.core")
require("config.input")
require("config.monitors")
require("config.env")
require("config.exec")
require("config.animations")
require("config.windowrules")
require("config.binds")
require("config.plugins")

-- DMS writes dms/colors.lua after Hyprland starts; first boot must still load.
pcall(require, "dms.colors")

-- hyprsplit is installed by lux under ~/.config/hypr/lux_packages.
-- Run: cd /etc/nixos/home/zerozawa/hyprland/lua && lx sync
local ok, hs = pcall(require, "hyprsplit")
if ok then
    hs.config({ num_workspaces = 10, persistent_workspaces = true })
end
