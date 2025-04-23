{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "redhat.vscode-xml"
  ];
  settings = {
    "[xml]" = {
      "editor.defaultFormatter" = "redhat.vscode-xml";
    };
  };
}
