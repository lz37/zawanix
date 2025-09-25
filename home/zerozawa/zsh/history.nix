{config, ...}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };
}
