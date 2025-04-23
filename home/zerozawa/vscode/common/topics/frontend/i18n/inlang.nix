{ pkgs,config, ... }:
{
  extensions = pkgs.nix4vscode.forVscode [
    "inlang.vs-code-extension"
  ];
  settings = {
    "sherlock.userId" = config.zerozawa.vscode.sherlock.userId;
  };
}
