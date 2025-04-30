{
  pkgs,
  isNvidiaGPU,
  hostName,
  ...
}:
{

  xdg.portal =
    {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
    }
    // (
      # can't work on kde or gnome, just on hyprland
      if isNvidiaGPU then
        {
          config = {
            common = {
              default = "wlr";
            };
          };
          wlr = {
            enable = true;
            settings = {
              screencast = {
                output_name = if hostName == "zawanix-glap" then "DP-1" else "";
                chooser_type = "simple";
                chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
                max_fps = 30;
              };
            };
          };
        }
      else
        { }
    );
}
