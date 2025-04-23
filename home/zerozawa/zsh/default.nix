{
  ...
}:

{
  imports = [
    ./aliases.nix
    ./history.nix
    ./oh-my-zsh.nix
    ./zplug.nix
  ];
  programs.zsh = {
    enable = true;
    autocd = true;
    historySubstringSearch.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
