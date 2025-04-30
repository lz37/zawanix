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
    dotDir = ".config/zsh";
    enableVteIntegration = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
        "match_prev_cmd"
      ];
    };
  };
}
