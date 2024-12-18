{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    btop
    thefuck
    fortune
    wakatime
    fd
    translate-shell
    tldr
  ];
}
