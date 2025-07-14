{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "fill-labs.dependi"
    "rust-lang.rust-analyzer.0.3.2519"
    "dustypomerleau.rust-syntax"
  ];
}
