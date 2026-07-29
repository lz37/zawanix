{
  pkgs,
  config,
  lib,
  ...
} @ inputs: let
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
in {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode-selected;
    # AI 时代不再按场景分 profile：所有 topic 统一合入 default。
    # 前 17 项保持旧 default profile 的原顺序（no-ai ++ ai ++ leetcode），其余 topic 追加在后。
    profiles.default =
      (merge-imports [
        # ── 旧 default profile 顺序 ──────────────────────
        (import ./common/topics/base.nix)
        (import ./common/topics/gui.nix)
        (import ./common/topics/lang.nix)
        (import ./common/topics/remote/ssh.nix)
        (import ./common/topics/remote/common.nix)
        (import ./common/topics/gitlens.nix)
        (import ./common/topics/docker.nix)
        (import ./common/topics/document/markdown.nix)
        (import ./common/topics/nix.nix)
        (import ./common/topics/remote/liveshare.nix)
        (import ./common/topics/frontend/prettier.nix)
        (import ./common/topics/settingfile/yaml.nix)
        (import ./common/topics/settingfile/xml.nix)
        (import ./common/topics/settingfile/toml.nix)
        (import ./common/topics/settingfile/json5.nix)
        (import ./common/topics/ai.nix)
        (import ./common/topics/leetcode.nix)
        # ── 其余 topic（原各专项 profile 独有）───────────
        (import ./common/topics/remote/devcontainer.nix)
        (import ./common/topics/ci-cd.nix)
        (import ./common/topics/python.nix)
        (import ./common/topics/go.nix)
        (import ./common/topics/rust.nix)
        (import ./common/topics/bash.nix)
        (import ./common/topics/cpp/clang.nix)
        (import ./common/topics/cpp/cmake.nix)
        (import ./common/topics/cpp/qt.nix)
        (import ./common/topics/cpp/xmake.nix)
        (import ./common/topics/java/base.nix)
        (import ./common/topics/java/spring.nix)
        (import ./common/topics/java/kotlin.nix)
        (import ./common/topics/frontend/base.nix)
        (import ./common/topics/frontend/astro.nix)
        (import ./common/topics/frontend/tailwind.nix)
        (import ./common/topics/frontend/styled-components.nix)
        (import ./common/topics/frontend/vue.nix)
        (import ./common/topics/document/drawio.nix)
        (import ./common/topics/settingfile/dotenv.nix)
        (import ./common/topics/k8s.nix)
        (import ./common/topics/novel.nix)
      ])
      // {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
      };
  };
  services.vscode-server.enable = true;
  home = {
    activation.vscode-argv-patch = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Code/User/settings.json";
        force = true;
      };
    };
  };
}
