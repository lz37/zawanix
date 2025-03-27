{ pkgs, ... }@inputs:
let
  merge-vscode-modules = import ./common/utils.nix;
  merge-imports = merge-vscode-modules ({ inherit pkgs; } // inputs);
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode;
    profiles = {
      default =
        (merge-imports [
          (import ./common/topics/base.nix)
          (import ./common/topics/gui.nix)
          (import ./common/topics/copilot.nix)
          (import ./common/topics/docker.nix)
          (import ./common/topics/gitlens.nix)
          (import ./common/topics/lang.nix)
          (import ./common/topics/markdown.nix)
          (import ./common/topics/nix.nix)
          (import ./common/topics/remote/ssh.nix)
          (import ./common/topics/remote/liveshare.nix)
          (import ./common/topics/frontend/base.nix)
          (import ./common/topics/frontend/prettier.nix)
          (import ./common/topics/settingfile/yaml.nix)
          (import ./common/topics/settingfile/xml.nix)
        ])
        // {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
        };
      tailwind = (
        merge-imports [
          (import ./common/topics/base.nix)
          (import ./common/topics/gui.nix)
          (import ./common/topics/copilot.nix)
          (import ./common/topics/gitlens.nix)
          (import ./common/topics/lang.nix)
          (import ./common/topics/nix.nix)
          (import ./common/topics/frontend/base.nix)
          (import ./common/topics/frontend/prettier.nix)
          (import ./common/topics/frontend/tailwind.nix)
          (import ./common/topics/settingfile/dotenv.nix)
        ]
      );
      frontend = (
        merge-imports [
          (import ./common/topics/base.nix)
          (import ./common/topics/gui.nix)
          (import ./common/topics/copilot.nix)
          (import ./common/topics/gitlens.nix)
          (import ./common/topics/lang.nix)
          (import ./common/topics/nix.nix)
          (import ./common/topics/frontend/base.nix)
          (import ./common/topics/frontend/prettier.nix)
          (import ./common/topics/settingfile/dotenv.nix)
        ]
      );
      devcontainer = (
        merge-imports [
          (import ./common/topics/base.nix)
          (import ./common/topics/gui.nix)
          (import ./common/topics/lang.nix)
          (import ./common/topics/docker.nix)
          (import ./common/topics/copilot.nix)
          (import ./common/topics/gitlens.nix)
          (import ./common/topics/remote/ssh.nix)
          (import ./common/topics/remote/devcontainer.nix)
        ]
      );
    };
  };
}
