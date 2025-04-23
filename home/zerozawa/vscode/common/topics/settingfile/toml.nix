{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "tamasfe.even-better-toml"
  ];
  settings = {
    "[toml]" = {
      "editor.defaultFormatter" = "tamasfe.even-better-toml";
    };
  };
}
