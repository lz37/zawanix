{ pkgs, lib, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    yzhang.markdown-all-in-one
    # "shd101wyy.markdown-preview-enhanced"
    davidanson.vscode-markdownlint
    bierner.markdown-mermaid
    (yzane.markdown-pdf.overrideAttrs (oldAttrs: {
      postInstall = ''
        jq '.contributes.configuration.properties."markdown-pdf.executablePath".default = "${lib.getExe pkgs.chromium}"' $out/$installPrefix/package.json | sponge $out/$installPrefix/package.json
      '';
    }))
  ];
  settings = {
    # markdown-preview-enhanced.previewTheme = "atom-dark.css";
    "[markdown]" = {
      "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
    "markdown-pdf.executablePath" = "${lib.getExe pkgs.chromium}";
  };
}
