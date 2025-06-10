{ pkgs, config, ... }@inputs:
let
  merge-vscode-modules = import ./common/utils.nix;
  merge-imports = merge-vscode-modules (
    {
      inherit pkgs;
      commonVSCVars = {
        wordSeparatorsStr = ''`~·!！@#$￥%^…&*()（）[]【】{}<>《》-—=+\|/、'‘’"“”:：;；,，.。?？'';
        prettierExtStr = "esbenp.prettier-vscode";
      };
    }
    // inputs
  );
  gui = [ (import ./common/topics/gui.nix) ];
  base = [ (import ./common/topics/base.nix) ];
  lang = [ (import ./common/topics/lang.nix) ];
  copilot = [ (import ./common/topics/copilot.nix) ];
  gitlens = [ (import ./common/topics/gitlens.nix) ];
  default =
    base
    ++ gui
    ++ lang
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/docker.nix)
      (import ./common/topics/document/markdown.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/remote/ssh.nix)
      (import ./common/topics/remote/liveshare.nix)
      (import ./common/topics/frontend/base.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/settingfile/yaml.nix)
      (import ./common/topics/settingfile/xml.nix)
    ];
  rust =
    base
    ++ gui
    ++ lang
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/rust.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/settingfile/toml.nix)
      (import ./common/topics/remote/ssh.nix)
      (import ./common/topics/document/markdown.nix)
    ];
  tailwind =
    base
    ++ gui
    ++ lang
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/document/markdown.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/frontend/base.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/frontend/tailwind.nix)
      (import ./common/topics/settingfile/dotenv.nix)
      (import ./common/topics/remote/ssh.nix)
    ];
  frontend =
    base
    ++ gui
    ++ lang
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/document/markdown.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/frontend/base.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/settingfile/dotenv.nix)
    ];
  noveler =
    base
    ++ gui
    ++ lang
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/nix.nix)
      (import ./common/topics/frontend/base.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/ci-cd.nix)
      (import ./common/topics/remote/ssh.nix)
      (import ./common/topics/settingfile/toml.nix)
      (import ./common/topics/settingfile/yaml.nix)
    ];
  ssh =
    base
    ++ gui
    ++ lang
    ++ [
      (import ./common/topics/docker.nix)
      (import ./common/topics/remote/ssh.nix)
    ];
  devcontainer = ssh ++ [
    (import ./common/topics/remote/devcontainer.nix)
  ];
  k8s = ssh ++ [ (import ./common/topics/k8s.nix) ];
  xd = default ++ [
    (import ./common/topics/ci-cd.nix)
    (import ./common/topics/python.nix)
    (import ./common/topics/bash.nix)
    (import ./common/topics/document/drawio.nix)
  ];
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode;
    profiles = {
      default = (merge-imports default) // {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
      };
      tailwind = (merge-imports tailwind);
      frontend = (merge-imports frontend);
      noveler = (merge-imports noveler);
      ssh = (merge-imports ssh);
      devcontainer = (merge-imports devcontainer);
      k8s = (merge-imports k8s);
      rust = (merge-imports rust);
      xd = (merge-imports xd);
    };
  };
  services.vscode-server.enable = true;
  home.file = {
    ".vscode-server/extensions" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.vscode/extensions";
      force = true;
    };
    ".vscode-server/data/Machine/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Code/settings.json";
      force = true;
    };
    ".vscode-server/data/User/profiles" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Code/User/profiles";
      force = true;
    };
  };
}
