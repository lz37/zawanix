{ ... }@inputs:

let
  merge-vscode-modules = import ../common/utils.nix;
in
{
  programs.vscode.profiles.default = merge-vscode-modules inputs [
    import
    ../common/topics/base.nix
    import
    ../common/topics/gui.nix
  ];
}
