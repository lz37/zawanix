{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "mikestead.dotenv"
  ];
}
