{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "github.vscode-github-actions"
    "gitlab.gitlab-workflow"
  ];
}
