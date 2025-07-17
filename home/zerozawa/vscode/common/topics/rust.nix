{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    fill-labs.dependi
    rust-lang.rust-analyzer
    dustypomerleau.rust-syntax
  ];
}
