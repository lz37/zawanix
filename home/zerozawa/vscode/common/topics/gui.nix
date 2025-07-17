{ pkgs, commonVSCVars, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    usernamehw.errorlens
    fisheva.eva-theme
    pkief.material-icon-theme
    oderwat.indent-rainbow
    naumovs.color-highlight
    adpyke.codesnap
  ];
  settings = {
    "accessibility.signalOptions.volume" = 0;
    "indentRainbow.errorColor" = "rgba(128,32,32,0.6)";
    "indentRainbow.colors" = [
      "rgba(255,0,255,0.07)"
      "rgba(0,0,255,0.07)"
      "rgba(0,255,255,0.07)"
      "rgba(0,255,0,0.07)"
      "rgba(255,255,0,0.07)"
      "rgba(255,125,0,0.07)"
      "rgba(255,0,0,0.07)"
    ];
    "editor.fontFamily" = "Sarasa Mono SC";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 16;
    "editor.inlineSuggest.enabled" = true;
    "editor.minimap.showSlider" = "always";
    "editor.minimap.side" = "right";
    "editor.minimap.size" = "fill";
    "editor.renderWhitespace" = "all";
    "editor.scrollbar.verticalScrollbarSize" = 0;
    "editor.wordSeparators" = commonVSCVars.wordSeparatorsStr;
    "editor.wordWrap" = "bounded";
    "editor.wordWrapColumn" = 120;
    "editor.wrappingIndent" = "same";
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
    "terminal.integrated.fontFamily" =
      "FiraCode Nerd Font Mono,MesloLGS NF,LXGW WenKai Mono,Source Han Mono";
    "terminal.integrated.fontLigatures.enabled" = true;
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.inheritEnv" = false;
    "terminal.integrated.wordSeparators" = commonVSCVars.wordSeparatorsStr;
    "workbench.colorTheme" = "Eva Dark Italic";
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.editor.wrapTabs" = true;
    "workbench.externalBrowser" = "${pkgs.vivaldi}/bin/vivaldi";
    "window.zoomLevel" = 1;
    "window.titleBarStyle" = "native";
    "window.customTitleBarVisibility" = "never";
  };
  keybindings = [
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
  ];
}
