{
  ...
}:

{
  programs.zsh = {
    zplug = {
      enable = true;
      # Installations with additional options. For the list of options, please refer to Zplug README.
      plugins = [
        {
          name = "romkatv/powerlevel10k";
          tags = [
            "as:theme"
            "depth:1"
          ];
        }
        { name = "fdellwing/zsh-bat"; }
        { name = "wbingli/zsh-wakatime"; }
        { name = "MichaelAquilina/zsh-you-should-use"; }
        { name = "MenkeTechnologies/zsh-cargo-completion"; }
        { name = "nix-community/nix-zsh-completions"; }
        { name = "BronzeDeer/zsh-completion-sync"; } # work with XDG_DATA_DIRS env var
      ];
    };
  };
}
