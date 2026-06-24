local opt = require("option")

-- Startup commands executed once on Hyprland start
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
    hl.exec_cmd("bash -c 'wl-paste --type text --watch cliphist store &'")
    hl.exec_cmd("bash -c 'wl-paste --type image --watch cliphist store &'")
    hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    hl.exec_cmd("pypr")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/bin/pam_kwallet_init")
    hl.exec_cmd("kwalletd6")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("jellyfin-mpv-shim")
    hl.exec_cmd("remmina")
    hl.exec_cmd("svp")
    hl.exec_cmd("telegram-desktop")
    if opt.features and opt.features.nm_applet then
        hl.exec_cmd("nm-applet --indicator")
    end
end)
