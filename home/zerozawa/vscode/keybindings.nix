{ config, pkgs, ... }:
{
  programs.vscode.keybindings = [
    {
      key = "shift+alt+f";
      command = "editor.action.formatDocument";
      when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
    }
    {
      key = "shift+alt+f";
      command = "editor.action.formatDocument.none";
      when = "editorTextFocus && !editorHasDocumentFormattingProvider && !editorReadonly";
    }
    {
      key = "alt+n";
      command = "explorer.newFile";
    }
    {
      key = "shift+alt+n";
      command = "explorer.newFolder";
    }
    {
      key = "ctrl+enter";
      command = "-github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated && !inInteractiveInput && !interactiveEditorFocused";
    }
    {
      key = "ctrl+shift+alt+enter";
      command = "github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated && !inInteractiveInput && !interactiveEditorFocused";
    }
  ];
}
