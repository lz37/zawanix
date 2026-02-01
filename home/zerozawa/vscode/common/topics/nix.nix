{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    jnoortheen.nix-ide
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
