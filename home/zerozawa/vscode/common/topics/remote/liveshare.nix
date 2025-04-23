{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-vsliveshare.vsliveshare"
  ];
}
