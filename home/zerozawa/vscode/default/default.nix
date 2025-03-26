{ pkgs, ... }@inputs:

let
  merge-vscode-modules = import ../common/utils.nix;
in
{
  programs.vscode.profiles = {
    default = (
      merge-vscode-modules ({ inherit pkgs; } // inputs) [
        (import ../common/topics/base.nix)
        (import ../common/topics/gui.nix)
        (import ../common/topics/copilot.nix)
        (import ../common/topics/docker.nix)
        (import ../common/topics/gitlens.nix)
        (import ../common/topics/lang.nix)
        (import ../common/topics/markdown.nix)
        (import ../common/topics/nix.nix)
        (import ../common/topics/remote/ssh.nix)
        (import ../common/topics/remote/liveshare.nix)
        (import ../common/topics/frontend/base.nix)
        (import ../common/topics/frontend/prettier.nix)
        (import ../common/topics/settingfile/yaml.nix)
        (import ../common/topics/settingfile/xml.nix)
      ]
    );
    devcontainer=(
      merge-vscode-modules ({ inherit pkgs; } // inputs) [
        (import ../common/topics/base.nix)
        (import ../common/topics/gui.nix)
        (import ../common/topics/docker.nix)
        (import ../common/topics/remote/devcontainer.nix)
      ]
    );
  };

}
