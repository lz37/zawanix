local opt = require("option")

-- Startup commands executed once on Hyprland start
hl.on("hyprland.start", function()
    hl.exec_cmd(
    "dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
    hl.exec_cmd("bash -c 'wl-paste --type text --watch cliphist store &'")
    hl.exec_cmd("bash -c 'wl-paste --type image --watch cliphist store &'")
    hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_MODULES")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_MODULES")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    hl.exec_cmd("pypr")
    -- kwalletd6 必须先启动，pam_kwallet_init 才能连上它解锁
    hl.exec_cmd("kwalletd6")
    hl.exec_cmd("bash -c 'sleep 1 && " .. os.getenv("HOME") .. "/.config/hypr/bin/pam_kwallet_init'")
    -- 空密码 wallet 需显式 open 一次（pam_kwallet_init 用 PAM 密码对空密码无效）
    hl.exec_cmd("bash -c 'sleep 2 && kwallet-query -f \"\" -l kdewallet >/dev/null 2>&1'")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("jellyfin-mpv-shim")
    hl.exec_cmd("remmina")
    hl.exec_cmd("svp")
    hl.exec_cmd("telegram-desktop")
    if opt.features and opt.features.nm_applet then
        hl.exec_cmd("nm-applet --indicator")
    end
end)
