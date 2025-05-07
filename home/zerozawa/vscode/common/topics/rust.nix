{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "fill-labs.dependi"
    "rust-lang.rust-analyzer"
    "dustypomerleau.rust-syntax"
  ];
}
