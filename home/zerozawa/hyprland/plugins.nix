{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.unstable-hyprland.plugins; [
      hypr-dynamic-cursors
      split-monitor-workspaces
      xtra-dispatchers
      # hyprfocus
    ];
    settings = {
      plugin = {
        hyprfocus = {
          enabled = "yes";
          animate_floating = "no";
          animate_workspacechange = "no";
          focus_animation = "shrink";
          # Beziers for focus animations
          bezier = [
            "bezIn, 0.5, 0.0, 1.0, 0.5"
            "bezOut, 0.0, 0.5, 0.5, 1.0"
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
            "realsmooth, 0.28, 0.29, 0.69, 1.08"
            "easeInOutBack, 0.68, -0.6, 0.32, 1.6"
          ];
          # Flash settings
          flash = {
            flash_opacity = 0.7;
            in_bezier = "bezIn";
            in_speed = "0.5";
            out_bezier = "bezOut";
            out_speed = 3;
          };
          # Shrink settings
          shrink = {
            shrink_percentage = 0.99;
            in_bezier = "easeInOutBack";
            in_speed = 1.5;
            out_bezier = "easeInOutBack";
            out_speed = 3;
          };
        };
        split-monitor-workspaces = {
          count = 5;
          enable_notifications = true;
          enable_persistent_workspaces = true;
        };
        dynamic-cursors = {
          enabled = true;
          mode = "none";
          # configure shake to find
          # magnifies the cursor if its is being shaken
          shake = {
            # enables shake to find
            enabled = true;
            # use nearest-neighbour (pixelated) scaling when shaking
            # may look weird when effects are enabled
            nearest = true;
            # controls how soon a shake is detected
            # lower values mean sooner
            threshold = 6.0;
            # magnification level immediately after shake start
            base = 4.0;
            # magnification increase per second when continuing to shake
            speed = 4.0;
            # how much the speed is influenced by the current shake intensitiy
            influence = 0.0;
            # maximal magnification the cursor can reach
            # values below 1 disable the limit (e.g. 0)
            limit = 0.0;
            # time in millseconds the cursor will stay magnified after a shake has ended
            timeout = 2000;
            # show cursor behaviour `tilt`, `rotate`, etc. while shaking
            effects = false;
            # enable ipc events for shake
            # see the `ipc` section below
            ipc = false;
          };
          hyprcursor = {
            # use nearest-neighbour (pixelated) scaling when magnifing beyond texture size
            # this will also have effect without hyprcursor support being enabled
            # 0 / false - never use pixelated scaling
            # 1 / true  - use pixelated when no highres image
            # 2         - always use pixleated scaling
            nearest = true;
            # enable dedicated hyprcursor support
            enabled = true;
            # resolution in pixels to load the magnified shapes at
            # be warned that loading a very high-resolution image will take a long time and might impact memory consumption
            # -1 means we use [normal cursor size] * [shake:base option]
            resolution = -1;
            # shape to use when clientside cursors are being magnified
            # see the shape-name property of shape rules for possible names
            # specifying clientside will use the actual shape, but will be pixelated
            fallback = "clientside";
          };
        };
        # virtual-desktops = {
        #   names = "1:coding, 2:internet, 3:chats, 4:games";
        #   cycleworkspaces = 1;
        #   rememberlayout = "size";
        #   notifyinit = 0;
        #   verbose_logging = 0;
        # };
      };
    };
  };
}
