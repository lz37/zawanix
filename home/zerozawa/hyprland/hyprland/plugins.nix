{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      # hyprwinwrap
      # hypr-dynamic-cursors
    ];
    settings = {
      # "plugin:dynamic-cursors" = {
      #   enabled = true;
      #   mode = "none";
      #   # configure shake to find
      #   # magnifies the cursor if its is being shaken
      #   shake = {
      #     # enables shake to find
      #     enabled = true;
      #     # use nearest-neighbour (pixelated) scaling when shaking
      #     # may look weird when effects are enabled
      #     nearest = true;
      #     # controls how soon a shake is detected
      #     # lower values mean sooner
      #     threshold = 6.0;
      #     # magnification level immediately after shake start
      #     base = 4.0;
      #     # magnification increase per second when continuing to shake
      #     speed = 4.0;
      #     # how much the speed is influenced by the current shake intensitiy
      #     influence = 0.0;
      #     # maximal magnification the cursor can reach
      #     # values below 1 disable the limit (e.g. 0)
      #     limit = 0.0;
      #     # time in millseconds the cursor will stay magnified after a shake has ended
      #     timeout = 2000;
      #     # show cursor behaviour `tilt`, `rotate`, etc. while shaking
      #     effects = false;
      #     # enable ipc events for shake
      #     # see the `ipc` section below
      #     ipc = false;
      #   };
      #   hyprcursor = {
      #     # use nearest-neighbour (pixelated) scaling when magnifing beyond texture size
      #     # this will also have effect without hyprcursor support being enabled
      #     # 0 / false - never use pixelated scaling
      #     # 1 / true  - use pixelated when no highres image
      #     # 2         - always use pixleated scaling
      #     nearest = true;
      #     # enable dedicated hyprcursor support
      #     enabled = true;
      #     # resolution in pixels to load the magnified shapes at
      #     # be warned that loading a very high-resolution image will take a long time and might impact memory consumption
      #     # -1 means we use [normal cursor size] * [shake:base option]
      #     resolution = -1;
      #     # shape to use when clientside cursors are being magnified
      #     # see the shape-name property of shape rules for possible names
      #     # specifying clientside will use the actual shape, but will be pixelated
      #     fallback = "clientside";
      #   };
      # };
      plugin = {
        # virtual-desktops = {
        #   names = "1:coding, 2:internet, 3:chats, 4:games";
        #   cycleworkspaces = 1;
        #   rememberlayout = "size";
        #   notifyinit = 0;
        #   verbose_logging = 0;
        # };
        # hyprwinwrap = rec {
        #   class = "kitty-bg";
        #   # you can also use title
        #   title = class;
        #   # you can add the position of the window in a percentage
        #   pos_x = 25;
        #   pos_y = 30;
        #   # you can add the size of the window in a percentage
        #   size_x = 40;
        #   size_y = 70;
        # };
      };
    };
  };
}
