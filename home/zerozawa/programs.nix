{ pkgs,config,... }:

{
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      config = {
        whitelist.prefix = [ config.zerozawa.nixos.path.code ];
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
      extraConfig = {
        credential = {
          helper = "store";
        };
      };
    };
  };

}
