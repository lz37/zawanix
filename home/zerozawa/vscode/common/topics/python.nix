{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-python.python"
    "ms-python.black-formatter"
  ];
  settings = {
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.formatOnType" = true;
    };
  };
}
