{
  pkgs,
  lib,
  ...
}: {
  extensions = with pkgs; ((with vscode-selected-extensionsCompatible.vscode-marketplace; [
      (github.copilot.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [libcxx];
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [autoPatchelfHook];
      }))
    ])
    ++ (with vscode-marketplace-release; [
      github.copilot-chat
    ]));
  settings = {
    "chat.agent.enabled" = true;
    "chat.editor.wordWrap" = "on";
    "chat.mcp.discovery.enabled" = {
      "claude-desktop" = true;
      "windsurf" = true;
      "cursor-global" = true;
      "cursor-workspace" = true;
    };
    "chat.useFileStorage" = true;
    "github.copilot.enable" = {
      "*" = true;
      "plaintext" = true;
      "markdown" = true;
      "scminput" = false;
    };
    "github.copilot.advanced" = {
      "authPermissions" = "default";
      "authProvider" = "github";
      "useLanguageServer" = true;
    };
    "github.copilot.editor.enableCodeActions" = true;
    "github.copilot.nextEditSuggestions.enabled" = true;
    "github.copilot.nextEditSuggestions.fixes" = true;
    "github.copilot.renameSuggestions.triggerAutomatically" = true;
    "github.copilot.chat.agent.thinkingTool" = true;
    "github.copilot.chat.agent.autoFix" = true;
    "github.copilot.chat.codesearch.enabled" = true;
    "github.copilot.chat.editor.temporalContext.enabled" = true;
    "github.copilot.chat.edits.temporalContext.enabled" = true;
    "github.copilot.chat.edits.suggestRelatedFilesFromGitHistory" = true;
    "github.copilot.chat.edits.suggestRelatedFilesForTests" = true;
    "github.copilot.chat.languageContext.fix.typescript.enabled" = true;
    "github.copilot.chat.languageContext.inline.typescript.enabled" = true;
    "github.copilot.chat.languageContext.typescript.enabled" = true;
    "github.copilot.chat.terminalChatLocation" = "terminal";
    "github.copilot.chat.summarizeAgentConversationHistory.enabled" = true;
    "github.copilot.chat.scopeSelection" = true;
    "github.copilot.chat.generateTests.codeLens" = true;
    "accessibility.voice.speechLanguage" = "zh-CN";
  };
  keybindings = [
    {
      key = "ctrl+enter";
      command = "-github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated && !commentEditorFocused";
    }
    {
      key = "ctrl+shift+alt+enter";
      command = "github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated && !commentEditorFocused";
    }
  ];
  mcp = {
    nixos = {
      command = lib.getExe pkgs.mcp-nixos;
    };
  };
}
