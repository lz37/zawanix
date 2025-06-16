{
  config,
  pkgs,
  colorsh,
  ...
}:

{
  imports = [
    ./programs.nix
    ./zsh
    ./services.nix
    ./xdg.nix
    ./neovim.nix
    ./vscode
    ./hyprland
    ./tmux.nix
    ./podman.nix
    ./icon.nix
    ./plasma
    ./activation
    ./browser
    ./browser/electron-flags.nix
    ./ssh.nix
  ];
  home = {
    stateVersion = config.zerozawa.version.home-manager-version;
  };
  home.packages = [
    (
      let
        packages = builtins.map (p: "${p.name}") config.home.packages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
      pkgs.writeScriptBin "zawanix.zerozawa.packages" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.coreutils}/bin/echo -e "${formatted}"
        ${pkgs.coreutils}/bin/echo -e "${
          colorsh.utils.chunibyo.gothic.kaomoji.unicode {
            gothic = "𝔷𝔞𝔴𝔞𝔦𝔫𝔦𝔵";
            scope = "魔導使い個人書庫";
            splitter = "";
            action = "に眠る秘儀${builtins.toString (builtins.length sortedUnique)}式";
            kaomoji = "(｡•̀ᴗ-)✧";
            unicode = "📖✨";
          }
        }"
      ''
    )
  ];
}
