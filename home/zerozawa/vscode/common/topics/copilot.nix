{ pkgs, ... }:

{
  extensions = with pkgs.stable.vscode-extensions; [
    github.copilot
    github.copilot-chat
  ];
  settings = {
    "github.copilot.editor.enableAutoCompletions" = true;
    "chat.agent.enabled" = true;
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
}
