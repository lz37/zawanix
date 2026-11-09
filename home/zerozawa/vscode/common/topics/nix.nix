{ pkgs, ... }: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    jnoortheen.nix-ide
    pkgs.vscode-extra.barsikus007.nix-injection
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
