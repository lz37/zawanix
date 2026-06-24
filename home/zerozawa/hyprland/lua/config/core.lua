local opt = require("option")

hl.config({
    xwayland = {
        force_zero_scaling = true,
        create_abstract_socket = true,
    },
    general = {
        allow_tearing = true,
        layout = "dwindle",
        gaps_in = 6,
        gaps_out = 8,
        border_size = 2,
        resize_on_border = true,
        col = {
            active_border = { colors = { "rgb(cba6f7)", "rgb(89dceb)" }, angle = 45 },
            inactive_border = "rgb(45475a)",
        },
    },
    misc = {
        layers_hog_keyboard_focus = true,
        initial_workspace_tracking = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = false,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        enable_swallow = false,
        vrr = 0,
        enable_anr_dialog = true,
        anr_missed_pings = 15,
    },
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 5,
            passes = 3,
            ignore_opacity = true,
            new_optimizations = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },
    ecosystem = {
        no_donation_nag = true,
        no_update_news = false,
    },
    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = 2,
        enable_hyprcursor = true,
        warp_on_change_workspace = 2,
        no_warps = true,
    },
    render = {
        direct_scanout = opt.hardware.isOculink and 0 or 1,
    },
    master = {
        new_status = "master",
        new_on_top = 1,
        mfact = 0.5,
    },
})
