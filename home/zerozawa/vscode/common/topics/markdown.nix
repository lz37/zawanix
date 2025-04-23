{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "yzhang.markdown-all-in-one"
    # shd101wyy.markdown-preview-enhanced
    "davidanson.vscode-markdownlint"
  ];
  settings = {
    # markdown-preview-enhanced.previewTheme = "atom-dark.css";
    "[markdown]" = {
      "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
  };
}
