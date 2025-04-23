{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "jetpack-io.devbox"
  ];
  settings = {
    "devbox.autoShellOnTerminal" = false;
  };
}
