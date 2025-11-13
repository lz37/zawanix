{
  config,
  pkgs,
  colorsh,
  ...
}: {
  imports = [
    ./programs.nix
    ./zsh
    ./xdg.nix
    ./vscode
    ./hyprland
    ./tmux.nix
    ./podman.nix
    ./plasma
    ./activation
    ./browser
    ./ssh.nix
    ./kitty.nix
    ./fastfetch
    ./zoxide.nix
    ./tealdeer.nix
    ./swappy.nix
    ./btop.nix
    ./obs-studio.nix
    ./nvf.nix
    ./lazygit.nix
    ./bat.nix
    ./bottom.nix
    ./htop.nix
    ./theme.nix
    ./git.nix
    ./eza.nix
    ./fzf.nix
    ./cava.nix
    ./yazi
    ./wlogout
    ./scripts
    ./mimelist.nix
    ./rofi
    ./mpv.nix
    ./autostart.nix
    ./input-method
    ./dms.nix
    ./clock-rs.nix
    ./ghostty.nix
    ./wezterm.nix
  ];
  home = {
    stateVersion = config.zerozawa.version.home-manager-version;
    packages = [
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
  };
}
