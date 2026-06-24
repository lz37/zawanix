hl.config({
    input = {
        kb_layout = "us",
        kb_options = "grp:alt_caps_toggle,caps:super",
        numlock_by_default = true,
        repeat_delay = 300,
        follow_mouse = 1,
        float_switch_override_focus = 0,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            scroll_factor = 0.8,
        },
    },
    gestures = {
        workspace_swipe_distance = 500,
        workspace_swipe_invert = 1,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = 1,
        workspace_swipe_forever = 1,
    },
})
