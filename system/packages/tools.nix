{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    fortune
    wakatime
    fd
    translate-shell
    tldr
    ventoy-full
  ];
}
