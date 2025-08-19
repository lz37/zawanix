{ lib, pkgs, ... }:
let
  inherit ((import ./utils.nix) { inherit lib pkgs; }) hyprlock-background;
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${lib.getExe hyprlock-background}";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        {
          timeout = 180;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 240;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 540;
          on-timeout = "pidof steam || systemctl suspend || loginctl suspend";
        }
      ];
    };
  };
}
