{ pkgs, ... }:
{
  stylix.targets.mpv.enable = true;
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      modernx
      memo
      mpv-notify-send
    ];
    config = {
      autoload-files = "yes";
    };
  };
}
