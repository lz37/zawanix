{ config, ... }:
let
  wordSeparatorsStr = ''`~·!！@#$￥%^…&*()（）[]【】{}<>《》-—=+\|/、'‘’"“”:：;；,，.。?？'';
  prettierExtStr = "esbenp.prettier-vscode";
in
{
  programs.vscode.userSettings = {
    "[cpp]" = {
      editor.tabSize = 2;
    };
    "[css]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[dockercompose]" = {
      editor.defaultFormatter = "ms-azuretools.vscode-docker";
    };
    "[html]" = {
      editor = {
        defaultFormatter = prettierExtStr;
        tabSize = 2;
      };
    };
    "[java]" = { };
    "[javascript]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[javascriptreact]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[json]" = {
      editor = {
        defaultFormatter = prettierExtStr;
        tabSize = 2;
      };
    };
    "[jsonc]" = {
      editor = {
        defaultFormatter = prettierExtStr;
        tabSize = 2;
      };
    };
    "[less]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[markdown]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[nix]" = {
      editor.defaultFormatter = "jnoortheen.nix-ide";
    };
    "[python]" = {
      editor = {
        defaultFormatter = "ms-python.black-formatter";
        formatOnType = true;
      };
    };
    "[scss]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[shellscript]" = {
      editor.defaultFormatter = "foxundermoon.shell-format";
    };
    "[spring-boot-properties-yaml]" = {
      editor.tabSize = 2;
    };
    "[typescript]" = {
      editor = {
        defaultFormatter = prettierExtStr;
        tabSize = 2;
      };
    };
    "[typescriptreact]" = {
      editor = {
        defaultFormatter = prettierExtStr;
        tabSize = 2;
      };
    };
    "[vue]" = {
      editor.defaultFormatter = prettierExtStr;
    };
    "[xml]" = {
      editor.defaultFormatter = "redhat.vscode-xml";
    };
    "[yaml]" = {
      editor = {
        defaultFormatter = "redhat.vscode-yaml";
        tabSize = 2;
      };
    };
    accessibility.signalOptions.volume = 0;
    cmake.configureOnOpen = true;
    cSpell.customDictionaries = {
      custom-dic = {
        addWords = true;
        name = "custom-dic";
        description = "custom words";
        path = "${config.xdg.configHome}/home-manager/profile/cspell/custom.txt";
      };
      custom = true;
      internal-terms = false;
    };
    code-runner.runInTerminal = true;
    debug.onTaskErrors = "abort";
    dev.containers = {
      copyGitConfig = true;
      cacheVolume = true;
      mountWaylandSocket = false;
      # defaultExtensions = [
      #   "streetsidesoftware.code-spell-checker"
      #   "naumovs.color-highlight"
      #   "GitHub.vscode-github-actions"
      #   "GitHub.copilot"
      #   "eamodio.gitlens"
      #   "oderwat.indent-rainbow"
      #   "yzhang.markdown-all-in-one"
      #   "shd101wyy.markdown-preview-enhanced"
      #   "DavidAnson.vscode-markdownlint"
      #   "christian-kohler.path-intellisense"
      #   "esbenp.prettier-vscode"
      #   "WakaTime.vscode-wakatime"
      #   "redhat.vscode-xml"
      #   "redhat.vscode-yaml"
      #   "kisstkondoros.vscode-gutter-preview"
      #   "bradlc.vscode-tailwindcss"
      # ];
    };
    devbox.autoShellOnTerminal = false;
    editor = {
      fontFamily = "Sarasa Mono CL";
      fontLigatures = true;
      fontSize = 16;
      inlineSuggest.enabled = true;
      minimap = {
        showSlider = "always";
        side = "right";
        size = "fill";
      };
      renderWhitespace = "all";
      scrollbar.verticalScrollbarSize = 0;
      wordSeparators = wordSeparatorsStr;
      wordWrap = "bounded";
      wordWrapColumn = 120;
      wrappingIndent = "same";
    };
    emmet.includeLanguages = {
      "javascript" = "javascriptreact";
      "typescript" = "typescriptreact";
    };
    explorer = {
      confirmDelete = false;
      confirmDragAndDrop = false;
    };
    extensions = {
      experimental.affinity = {
        "asvetliakov.vscode-neovim" = 1;
        "vscodevim.vim" = 1;
        "formulahendry.auto-rename-tag" = 2;
        "formulahendry.auto-close-tag" = 2;
        "wakatime.vscode-wakatime" = 2;
        "usernamehw.errorlens" = 2;
        "eamodio.gitlens" = 2;
        "tintinweb.vscode-inline-bookmarks" = 2;
        "oderwat.indent-rainbow" = 2;
        "naumovs.color-highlight" = 2;
        "github.copilot" = 3;
        "bradlc.vscode-tailwindcss" = 4;
        "christian-kohler.path-intellisense" = 4;
        "streetsidesoftware.code-spell-checker" = 4;
        "rust-lang.rust-analyzer" = 4;
        "redhat.vscode-yaml" = 4;
        "redhat.vscode-xml" = 4;
        "mikestead.dotenv" = 4;
        "tamasfe.even-better-toml" = 4;
        "ms-edgedevtools.vscode-edge-devtools" = 5;
        "ms-python.black-formatter" = 6;
        "foxundermoon.shell-format" = 6;
        "esbenp.prettier-vscode" = 6;
        "dbaeumer.vscode-eslint" = 6;
        "davidanson.vscode-markdownlint" = 6;
        "jnoortheen.nix-ide" = 7;
      };
    };
    files = {
      associations = {
        "*.env.*" = "dotenv";
        "*.json5" = "json";
        "flake.lock" = "json";
      };
      trimTrailingWhitespace = true;
    };
    git.openRepositoryInParentFolders = "never";
    "github.copilot.editor.enableAutoCompletions" = true;
    go.toolsManagement.autoUpdate = true;
    http.proxySupport = "on";
    indentRainbow = {
      colors = [
        "rgba(255,0,255,0.07)"
        "rgba(0,0,255,0.07)"
        "rgba(0,255,255,0.07)"
        "rgba(0,255,0,0.07)"
        "rgba(255,255,0,0.07)"
        "rgba(255,125,0,0.07)"
        "rgba(255,0,0,0.07)"
      ];
      errorColor = "rgba(128,32,32,0.6)";
    };
    javascript.updateImportsOnFileMove.enabled = "always";
    json.schemaDownload.enable = true;
    markdown-preview-enhanced.previewTheme = "atom-dark.css";
    redhat.telemetry.enabled = true;
    remote.SSH = {
      remotePlatform = {
        "192.168.2.4" = "linux";
        "192.168.2.11" = "linux";
        "192.168.2.9" = "linux";
      };
      useLocalServer = false;
    };
    security.workspace.trust.untrustedFiles = "open";
    sherlock.userId = config.zerozawa.vscode.sherlock.userId;
    terminal = {
      integrated = {
        fontFamily = "MesloLGS NF";
        fontSize = 12;
        inheritEnv = false;
        wordSeparators = wordSeparatorsStr;
      };
    };
    typescript = {
      tsserver.maxTsServerMemory = 8192;
      updateImportsOnFileMove.enabled = "always";
    };
    vim.useSystemClipboard = true;
    workbench = {
      colorTheme = "Eva Dark Italic";
      editor.wrapTabs = true;
      iconTheme = "material-icon-theme";
    };
    window = {
      zoomLevel = 1;
      titleBarStyle = "native";
    };
  };

}
