{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "eamodio.gitlens"
  ];
  settings = {
    "gitlens.launchpad.indicator.enabled" = false;
  };
}
