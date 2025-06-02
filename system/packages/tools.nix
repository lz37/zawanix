{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    btop
    fortune
    wakatime
    fd
    translate-shell
    tldr
    ventoy-full
  ];
}
