{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "mads-hartmann.bash-ide-vscode"
    "jeff-hykin.better-shellscript-syntax"
    "rogalmic.bash-debug"
    "timonwong.shellcheck"
    "foxundermoon.shell-format"
  ];
  settings = {
    "shellcheck.executablePath" = "${pkgs.shellcheck}/bin/shellcheck";
  };
}
