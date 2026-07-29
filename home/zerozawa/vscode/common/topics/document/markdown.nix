{
  pkgs,
  lib,
  ...
}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    yzhang.markdown-all-in-one
    # "shd101wyy.markdown-preview-enhanced"
    davidanson.vscode-markdownlint
    # bierner.markdown-mermaid
    # mermaidchart.vscode-mermaid-chart
    yzane.markdown-pdf
    bpruitt-goddard.mermaid-markdown-syntax-highlighting
    unifiedjs.vscode-mdx
    ggfincke.vsc-mdx-preview
  ];
  settings = {
    # markdown-preview-enhanced.previewTheme = "atom-dark.css";
    "[markdown]" = {
      "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
    "markdown-pdf.executablePath" = "${lib.getExe pkgs.chromium}";
    "mdx-preview.preview.enableScripts" = true;
  };
}
