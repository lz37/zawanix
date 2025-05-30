{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "hediet.vscode-drawio"
  ];
}
