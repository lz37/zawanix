{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    styled-components.vscode-styled-components
  ];
}
