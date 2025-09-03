{ pkgs, ... }:
{
  stylix.targets.mpv.enable = true;
  programs.mpv = {
    enable = true;
    scripts = with pkgs; [ mpvScripts.mpris ];
    config = {
      autoload-files = "yes";
    };
  };
}
