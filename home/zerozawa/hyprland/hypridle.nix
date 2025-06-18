{ pkgs, ... }:
let
  hyprlock-background = ((import ./hyprlock-background.nix) { inherit pkgs; });
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${hyprlock-background}/bin/hyprlock-background";
        before_sleep_cmd = "loginctl lock-session";
      };

      listener = [
        {
          timeout = 180;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 240;
          on-timeout = "${pkgs.hyprland-git-pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland-git-pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
        {
          timeout = 540;
          on-timeout = "${pkgs.procps}/bin/pidof steam || systemctl suspend || loginctl suspend";
        }
      ];
    };
  };
}
