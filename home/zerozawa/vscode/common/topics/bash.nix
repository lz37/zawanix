{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "mads-hartmann.bash-ide-vscode"
  ];
}
