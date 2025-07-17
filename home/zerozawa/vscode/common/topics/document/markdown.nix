{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    yzhang.markdown-all-in-one
    # "shd101wyy.markdown-preview-enhanced"
    davidanson.vscode-markdownlint
    bierner.markdown-mermaid
    yzane.markdown-pdf
  ];
  settings = {
    # markdown-preview-enhanced.previewTheme = "atom-dark.css";
    "[markdown]" = {
      "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
    "markdown-pdf.executablePath" = "${pkgs.chromium}/bin/chromium";
  };
}
