{ pkgs,config, ... }:
{
  extensions = with pkgs.vscode-marketplace; [
    inlang.vs-code-extension
  ];
  settings = {
    "sherlock.userId" = config.zerozawa.vscode.sherlock.userId;
  };
}
