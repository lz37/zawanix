{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "hediet.vscode-drawio"
  ];
  settings = {
    # markdown-preview-enhanced.previewTheme = "atom-dark.css";
    "hediet.vscode-drawio.resizeImages" = true;
  };
}
