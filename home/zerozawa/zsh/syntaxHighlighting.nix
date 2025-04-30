{
  pkgs,
  lib,
  config,
  ...
}:
let
  zsh-url-highlighter = pkgs.stdenv.mkDerivation (finalAttrs: {
    version = "1.0.0";
    pname = "zsh-url-highlighter";

    src = pkgs.fetchFromGitHub {
      owner = "ascii-soup";
      repo = "zsh-url-highlighter";
      rev = finalAttrs.version;
      hash = "";
    };

    strictDeps = true;
    buildInputs = [ pkgs.zsh ];

    installFlags = [ "PREFIX=$(out)" ];

    meta = with lib; {
      description = "A plugin for zsh-syntax-highlighting that turns URLs green if they respond with a " good "** status, and red otherwise. Useful for checking URL typos.";
      homepage = "https://github.com/ascii-soup/zsh-url-highlighter";
    };
  });
in

{
  home.file = {
    "tmp/zsh-url-highlighter" = {
      source = zsh-url-highlighter;
    };
  };

  programs.zsh = {
    sessionVariables = {
      ZSH_HIGHLIGHT_MAXLENGTH = "512";
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "cursor"
        "root"
        "line"
      ];
    };
  };
}
