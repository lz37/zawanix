{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    bradlc.vscode-tailwindcss
  ];
}
