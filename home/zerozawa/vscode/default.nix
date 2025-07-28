{
  pkgs,
  config,
  lib,
  ...
}@inputs:
let
  merge-vscode-modules = import ./common/utils.nix;
  merge-imports = merge-vscode-modules (
    {
      inherit config lib pkgs;
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
  ssh =
    base
    ++ gui
    ++ lang
    ++ [
      (import ./common/topics/remote/ssh.nix)
      (import ./common/topics/remote/common.nix)
    ];
  devcontainer = ssh ++ [
    (import ./common/topics/remote/common.nix)
    (import ./common/topics/remote/devcontainer.nix)
  ];
  default =
    ssh
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/docker.nix)
      (import ./common/topics/document/markdown.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/remote/liveshare.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/settingfile/yaml.nix)
      (import ./common/topics/settingfile/xml.nix)
    ];
  nixos =
    ssh
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/docker.nix)
      (import ./common/topics/document/markdown.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/hyprland.nix)
    ];
  rust =
    ssh
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/rust.nix)
      (import ./common/topics/nix.nix)
      (import ./common/topics/settingfile/toml.nix)
      (import ./common/topics/document/markdown.nix)
    ];

  frontend =
    ssh
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
      (import ./common/topics/settingfile/yaml.nix)
    ];
  tailwind = frontend ++ [
    (import ./common/topics/frontend/tailwind.nix)
  ];
  styled = frontend ++ [
    (import ./common/topics/frontend/styled-components.nix)
  ];
  tailwind_styled = tailwind ++ [ (import ./common/topics/frontend/styled-components.nix) ];
  noveler =
    ssh
    ++ copilot
    ++ gitlens
    ++ [
      (import ./common/topics/nix.nix)
      (import ./common/topics/frontend/base.nix)
      (import ./common/topics/frontend/prettier.nix)
      (import ./common/topics/ci-cd.nix)
      (import ./common/topics/settingfile/toml.nix)
      (import ./common/topics/settingfile/yaml.nix)
    ];
  k8s =
    ssh
    ++ gitlens
    ++ [
      (import ./common/topics/k8s.nix)
      (import ./common/topics/settingfile/yaml.nix)
      (import ./common/topics/nix.nix)
    ]
    ++ copilot;
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
    package = pkgs.vscode-selected;
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
      nixos = (merge-imports nixos);
      styled = (merge-imports styled);
      tailwind_styled = (merge-imports tailwind_styled);
    };
  };
  services.vscode-server.enable = true;
  home = {
    activation.vscode-argv-patch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #!${pkgs.bash}/bin/bash
      ARGV_JSON="${config.home.homeDirectory}/.vscode/argv.json"
      if [ ! -s "$ARGV_JSON" ]; then
        echo "File $ARGV_JSON does not exist. Skip"
        exit 0
      fi
      JSONFILE="$(cat $ARGV_JSON)"
      JSON="$(${pkgs.nodejs}/bin/node -e "console.log(JSON.stringify($JSONFILE))")"
      EDITED_JSON="$(echo "$JSON" | ${pkgs.jq}/bin/jq '. + {"password-store": "kwallet6"}')"
      echo -e "$EDITED_JSON" > $ARGV_JSON
    '';
    file = {
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
  };

}
