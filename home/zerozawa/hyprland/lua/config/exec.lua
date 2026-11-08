local opt = require("option")

-- Startup commands executed once on Hyprland start
hl.on("hyprland.start", function()
    -- 不要手动 stop/start 会话 target：Hyprland 0.57 起自带 hyprland-session.target，
    -- 其 PropagatesStopTo=graphical-session.target 会把整个图形会话一起停掉。
    -- UWSM (withUWSM = true) 已经负责会话 target 与环境导出，这里只需补 dbus 环境。
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("bash -c 'wl-paste --type text --watch cliphist store &'")
    hl.exec_cmd("bash -c 'wl-paste --type image --watch cliphist store &'")
    hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_MODULES")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_MODULES")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    hl.exec_cmd("pypr")
    -- kwalletd6 必须先启动，pam_kwallet_init 才能连上它解锁
    hl.exec_cmd("kwalletd6")
    hl.exec_cmd("bash -c 'sleep 1 && pam_kwallet_init'") -- 需要设置空密码之后，使用密码库的应用才不会触发密码询问窗口
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("jellyfin-mpv-shim")
    hl.exec_cmd("remmina")
    hl.exec_cmd("telegram-desktop")
    if opt.features and opt.features.nm_applet then
        hl.exec_cmd("nm-applet --indicator")
    end
end)
