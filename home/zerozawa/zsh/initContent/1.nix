{
  config,
  lib,
  ...
}:

{

  programs.zsh = {
    initContent = lib.mkBefore ''
      (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
      if [[ -r "${config.xdg.configHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "${config.xdg.configHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
    '';
  };
}
