{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    jnoortheen.nix-ide
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
