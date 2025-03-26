{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    eamodio.gitlens
  ];
  settings = {
    "gitlens.launchpad.indicator.enabled" = false;
  };
}
