{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "bradlc.vscode-tailwindcss"
  ];
}
