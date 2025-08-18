{
  pkgs,
  config,
  ...
}:

{
  programs = {
    pay-respects = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--alias"
        "fk"
      ];
    };
    bash.enable = true;
    fish = {
      enable = true;
    };
    lazygit.enable = true;
    command-not-found.enable = false;
    btop.enable = true;
    bottom.enable = true;
    bat.enable = true;
    eza.enable = true;
    tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      keyMode = "vi";
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = config.zerozawa.atuin.server;
        search_mode = "prefix";
      };
    };
    mise = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      config = {
        whitelist.prefix = [ config.zerozawa.path.code ];
      };
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = config.zerozawa.git.userName;
      userEmail = config.zerozawa.git.userEmail;
      signing.format = "openpgp";
      extraConfig = {
        credential = {
          helper = "store";
        };
      };
    };
    kitty = {
      enable = true;
      font = {
        # package = pkgs.meslo-lgs-nf;
        # name = "MesloLGS NF";
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      shellIntegration = {
        mode = "no-cursor";
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
      themeFile = "Monokai_Soda";
      extraConfig = ''
        shell ${pkgs.zsh}/bin/zsh
        include ${config.zerozawa.path.kitty}
      '';
    };
    ripgrep-all = {
      enable = true;
    };
    ripgrep = {
      enable = true;
    };
  };

}
