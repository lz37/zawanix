{ pkgs, ... }: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    jnoortheen.nix-ide
    barsikus007.nix-injection
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
