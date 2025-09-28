{
  pkgs,
  commonVSCVars,
  config,
  lib,
  ...
}: let
  browser = ''${lib.getExe pkgs.vivaldi} ${lib.concatStringsSep " " (import ../../../browser/common.nix).commandLineArgs} --password-store=kwallet6'';
in {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    usernamehw.errorlens
    fisheva.eva-theme
    pkief.material-icon-theme
    oderwat.indent-rainbow
    naumovs.color-highlight
    huibizhang.codesnap-plus
  ];
  settings = {
    "accessibility.signalOptions.volume" = 0;
    "indentRainbow.errorColor" = "#${config.lib.stylix.colors.base05}";
    "indentRainbow.colors" = [
      "#${config.lib.stylix.colors.base0F}4d"
      "#${config.lib.stylix.colors.base0E}4d"
      "#${config.lib.stylix.colors.base0D}4d"
      "#${config.lib.stylix.colors.base0C}4d"
      "#${config.lib.stylix.colors.base0B}4d"
      "#${config.lib.stylix.colors.base0A}4d"
      "#${config.lib.stylix.colors.base09}4d"
      "#${config.lib.stylix.colors.base08}4d"
    ];
    "editor.fontFamily" = lib.mkForce "Sarasa Mono SC,JetBrainsMono Nerd Font Mono,monospace,Unifont";
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
    "terminal.integrated.fontFamily" = "MesloLGS Nerd Font Mono,FiraCode Nerd Font Mono,LXGW WenKai Mono,Source Han Mono,JetBrainsMono Nerd Font Mono,monospace,Unifont";
    "terminal.integrated.fontLigatures.enabled" = true;
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.inheritEnv" = false;
    "terminal.integrated.wordSeparators" = commonVSCVars.wordSeparatorsStr;
    # "workbench.colorTheme" = "Eva Dark Italic";
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.editor.wrapTabs" = true;
    "workbench.externalBrowser" = browser;
    "window.zoomLevel" = 1;
    # "window.titleBarStyle" = "native";
    "window.customTitleBarVisibility" = "never";
    "window.autoDetectColorScheme" = true;
    "workbench.preferredDarkColorTheme" = "Eva Dark Italic Bold";
    "workbench.preferredLightColorTheme" = "Eva Light Italic Bold";
    "workbench.experimental.share.enabled" = true;
    # "window.controlsStyle" = "native";
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
