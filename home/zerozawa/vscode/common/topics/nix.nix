{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.open-vsx; [
    jnoortheen.nix-ide
  ];
  settings = {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
  };
}
