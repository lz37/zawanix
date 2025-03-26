{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;

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
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    historySubstringSearch.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "extract"
        "git"
        "sudo"
        "thefuck"
        "z"
      ];
    };
    zplug = {
      enable = true;
      # Installations with additional options. For the list of options, please refer to Zplug README.
      plugins = [
        {
          name = "romkatv/powerlevel10k";
          tags = [
            "as:theme"
            "depth:1"
          ];
        }
        { name = "fdellwing/zsh-bat"; }
        { name = "wbingli/zsh-wakatime"; }
        { name = "MichaelAquilina/zsh-you-should-use"; }
        { name = "MenkeTechnologies/zsh-cargo-completion"; }
        { name = "nix-community/nix-zsh-completions"; }
      ];
    };
    envExtra = '''';
    initExtraFirst = ''
      (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
      if [[ -r "${config.xdg.configHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "${config.xdg.configHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
    '';
    initExtra = ''
      # p10k
      # To customize prompt, run `p10k configure` or edit ${(import ../../options/variable-pub.nix).path.p10k}.
      [[ ! -f ${(import ../../options/variable-pub.nix).path.p10k} ]] || source ${(import ../../options/variable-pub.nix).path.p10k}
    '';
  };
}
