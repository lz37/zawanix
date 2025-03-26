{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    mikestead.dotenv
  ];
}
