{lib, ...}: {
  programs.zsh = {
    initContent = lib.mkBefore ''
      autoload zcalc
      # Prevent zsh-completion-sync from setting ZSH_COMPDUMP=/dev/null,
      # which causes oh-my-zsh to fail on "rm -f /dev/null" at startup.
      zstyle ':completion-sync:compinit:experimental:frozen-first-cache' enabled yes
    '';
  };
}
