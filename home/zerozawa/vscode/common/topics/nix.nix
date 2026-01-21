{
  pkgs,
  lib,
  ...
}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    jnoortheen.nix-ide
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
  mcp = {
    nixos = {
      command = lib.getExe pkgs.mcp-nixos;
    };
  };
}
