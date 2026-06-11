{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    tintinweb.vscode-inline-bookmarks
    wakatime.vscode-wakatime
    streetsidesoftware.code-spell-checker
    christian-kohler.path-intellisense
    mkhl.direnv
    matthewnespor.vscode-color-identifiers-mode
    ms-vscode.wasm-wasi-core
    fill-labs.dependi
    ultram4rine.vscode-choosealicense
    vkhey.recomment-pro
    yutengjing.vscode-mcp-bridge
  ];
  settings = {
    "terminal.integrated.defaultProfile.linux" = "zsh";
    "debug.onTaskErrors" = "abort";
    "emmet.includeLanguages" = {
      "javascript" = "javascriptreact";
      "typescript" = "typescriptreact";
    };
    "editor.tabSize" = 2;
    "files.associations" = {
      "*.env.*" = "dotenv";
      "*.json5" = "json";
      "flake.lock" = "json";
    };
    "files.watcherExclude" = {
      "**/.git/objects/**" = true;
      "**/.git/subtree-cache/**" = true;
      "**/node_modules/*/**" = true;
      "**/target/**" = true;
      "**/dist/**" = true;
      "**/build/**" = true;
      "**/.direnv/**" = true;
      "**/.devenv/**" = true;
    };
    "files.trimTrailingWhitespace" = true;
    "git.openRepositoryInParentFolders" = "never";
    "http.proxySupport" = "on";
    "json.schemaDownload.enable" = true;
    "security.workspace.trust.untrustedFiles" = "open";
    "redhat.telemetry.enabled" = true;
    "colorIdentifiersMode.method" = "hash";
    # @todo add more settings
    # "extensions.experimental.affinity" = { };
    "json.schemaDownload.trustedDomains" = {
      "*" = true;
    };
  };
}
