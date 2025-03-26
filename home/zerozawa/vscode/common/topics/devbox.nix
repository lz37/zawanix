{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    jetpack-io.devbox
  ];
  settings = {
    "devbox.autoShellOnTerminal" = false;
  };
}
