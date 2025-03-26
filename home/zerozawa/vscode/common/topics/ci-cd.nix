{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    github.vscode-github-actions
  ];
}
