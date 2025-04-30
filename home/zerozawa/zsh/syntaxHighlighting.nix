{
  pkgs,
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
      hash = "sha256-NRlAKHaoXPKrAK+sz09Cyvj8pvnT85Ubh0Hrk4DmuxE=";
    };

    strictDeps = true;
    buildInputs = [ pkgs.zsh ];
    installPhase = ''
      mkdir -p $out/share/zsh-syntax-highlighting/highlighters/
      cp -r url $out/share/zsh-syntax-highlighting/highlighters/
    '';

    meta = {
      description = "A plugin for zsh-syntax-highlighting that turns URLs green if they respond with a \" good \"** status, and red otherwise. Useful for checking URL typos.";
      homepage = "https://github.com/ascii-soup/zsh-url-highlighter";
    };
  });
  zsh-syntax-highlighting-with-url-highlighter = pkgs.buildEnv {
    name = "zsh-syntax-highlighting-with-url-highlighter";
    paths = [
      pkgs.zsh-syntax-highlighting
      zsh-url-highlighter
    ];
  };
in

{

  programs.zsh = {
    localVariables = {
      ZSH_HIGHLIGHT_MAXLENGTH = "512";
      ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR = "${zsh-syntax-highlighting-with-url-highlighter}/share/zsh-syntax-highlighting/highlighters";
    };
    syntaxHighlighting = {
      enable = true;
      package = zsh-syntax-highlighting-with-url-highlighter;
      highlighters = [
        "brackets"
        "pattern"
        "regexp"
        "cursor"
        "root"
        "line"
        "url"
      ];
    };
  };
}
