{lib, ...}: {
  programs.zsh = {
    initContent = lib.mkAfter ''
      zstyle ':completion:*:*:docker:*' option-stacking yes
      zstyle ':completion:*:*:docker-*:*' option-stacking yes
      zstyle ':omz:plugins:eza' 'dirs-first' yes
      zstyle ':omz:plugins:eza' 'git-status' yes
      zstyle ':omz:plugins:eza' 'header' yes
      zstyle ':omz:plugins:eza' 'show-group' yes
      zstyle ':omz:plugins:eza' 'icons' yes
      zstyle ':omz:plugins:eza' 'color-scale' all
      zstyle ':omz:plugins:eza' 'color-scale-mode' fixed
      zstyle ':omz:plugins:eza' 'size-prefix' binary
      zstyle ':omz:plugins:eza' 'hyperlink' yes
      hitokoto
      autoload zcalc
    '';
  };
}
