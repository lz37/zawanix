{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "styled-components.vscode-styled-components"
  ];
}
