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
        "hitokoto"
        "z"
      ];
    };
  };
}
