{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "vue.volar"
  ];
}
