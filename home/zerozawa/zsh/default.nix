{
  ...
}:

{
  imports = [
    ./aliases.nix
    ./history.nix
    ./oh-my-zsh.nix
    ./zplug.nix
    ./syntaxHighlighting.nix
    ./initContent
  ];
  programs.zsh = {
    enable = true;
    autocd = true;
    historySubstringSearch.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
  };
}
