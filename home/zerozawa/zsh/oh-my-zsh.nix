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
        "vscode"
        "systemadmin"
        "tmux"
        "ssh"
        "docker"
        "kitty"
        "history"
        "eza"
        "encode64"
        "cp"
        "sudo"
      ];
    };
  };
}
