{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "redhat.vscode-yaml"
  ];
  settings = {
    "[yaml]" = {
      "editor.defaultFormatter" = "redhat.vscode-yaml";
      "editor.tabSize" = 2;
    };
  };
}
