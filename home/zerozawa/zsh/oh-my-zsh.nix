{
  ...
}:

{
  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "extract"
        "git"
        "sudo"
        "thefuck"
        "hitokoto"
        "z"
      ];
    };
  };
}
