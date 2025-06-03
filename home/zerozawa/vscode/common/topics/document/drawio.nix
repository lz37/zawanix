{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "hediet.vscode-drawio"
  ];
  settings = {
    "hediet.vscode-drawio.resizeImages" = true;
  };
}
