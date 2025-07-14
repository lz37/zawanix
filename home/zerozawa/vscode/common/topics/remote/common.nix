{
  pkgs,
  ...
}:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-vscode.remote-explorer"
  ];
}
