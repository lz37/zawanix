{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "jnoortheen.nix-ide"
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
