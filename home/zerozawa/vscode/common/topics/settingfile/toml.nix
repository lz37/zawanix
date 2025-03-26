{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    tamasfe.even-better-toml
  ];
  settings = {
    "[toml]" = {
      "editor.defaultFormatter" = "tamasfe.even-better-toml";
    };
  };
}
