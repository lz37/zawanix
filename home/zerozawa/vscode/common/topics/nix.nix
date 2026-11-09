{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.open-vsx; [
    jnoortheen.nix-ide
    barsikus007.nix-injection
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
