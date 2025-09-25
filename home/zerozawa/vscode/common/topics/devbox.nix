{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    jetpack-io.devbox
  ];
  settings = {
    "devbox.autoShellOnTerminal" = false;
  };
}
