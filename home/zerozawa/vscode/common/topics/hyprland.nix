{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "fireblast.hyprlang-vscode"
    "ewen-lbh.vscode-hyprls"
  ];
}
