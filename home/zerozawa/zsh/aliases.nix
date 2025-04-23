{
  pkgs,
  ...
}:

{
  programs.zsh = {
    shellAliases = {
      find = "${pkgs.fd}/bin/fd";
      ls = "${pkgs.eza}/bin/eza";
      wakatime = "${pkgs.wakatime}/bin/wakatime-cli";
      l = "${pkgs.eza}/bin/eza -lbF --git";
      ll = "${pkgs.eza}/bin/eza -lbF --git";
      la = "${pkgs.eza}/bin/eza -lbhHigmuSa --time-style=long-iso --git --color-scale";
      lx = "${pkgs.eza}/bin/eza -lbhHigmuSa@ --time-style=long-iso --git --color-scale";
      llt = "${pkgs.eza}/bin/eza -l --git --tree";
      lt = "${pkgs.eza}/bin/eza --tree --level=2";
      llm = "${pkgs.eza}/bin/eza -lbGF --git --sort=modified";
      lld = "${pkgs.eza}/bin/eza -lbhHGmuSa --group-directories-first";
    };
  };
}
