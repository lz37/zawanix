{pkgs, ...}: {
  programs.zsh = with pkgs; {
    # nixpkgs 有的插件用 home-manager 原生加载（无 zplug 运行时开销）
    plugins = [
      {
        name = "powerlevel10k";
        src = zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-you-should-use";
        src = zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "nix-zsh-completions";
        src = nix-zsh-completions;
        file = "share/zsh/plugins/nix-zsh-completions/nix-zsh-completions.plugin.zsh";
      }
    ];

    # nixpkgs 没有的插件继续用 zplug 管理
    zplug = {
      enable = true;
      plugins = [
        {name = "wbingli/zsh-wakatime";}
        {name = "MenkeTechnologies/zsh-cargo-completion";}
        {name = "BronzeDeer/zsh-completion-sync";} # work with XDG_DATA_DIRS env var
      ];
    };
  };
}
