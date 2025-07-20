{
  pkgs,
  ...
}:
let
  zsh-syntax-highlighting-with-url-highlighter = pkgs.buildEnv {
    name = "zsh-syntax-highlighting-with-url-highlighter";
    paths = with pkgs; [
      zsh-syntax-highlighting
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
