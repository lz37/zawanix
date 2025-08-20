{
  pkgs,
  inputs,
  system,
  ...
}:
{
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprwinwrap
      inputs.hyprland-virtual-desktops.packages.${system}.virtual-desktops
    ];
    settings.plugin = {
      virtual-desktops = {
        names = "1:coding, 2:internet, 3:chats, 4:games";
        cycleworkspaces = 1;
        rememberlayout = "size";
        notifyinit = 0;
        verbose_logging = 0;
      };
    };
  };
}
