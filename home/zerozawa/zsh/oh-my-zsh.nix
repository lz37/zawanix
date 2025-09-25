{...}: {
  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "extract"
        "git"
        "sudo"
        "hitokoto"
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
        "copypath"
      ];
    };
  };
}
