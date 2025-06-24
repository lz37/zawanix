{
  pkgs,
  ...
}:

{
  programs.zsh = {
    shellAliases = {
      find = "${pkgs.fd}/bin/fd";
      wakatime = "${pkgs.wakatime}/bin/wakatime-cli";
    };
  };
}
