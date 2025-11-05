{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    eamodio.gitlens
  ];
  settings = {
    "gitlens.launchpad.indicator.enabled" = false;
    "gitlens.ai.model" = "gitkraken";
    "gitlens.ai.enabled" = true;
    "gitlens.ai.vscode.model" = "anthropic:claude-4-5";
    "gitlens.ai.gitkraken.model" = "gemini:gemini-2.0-flash";
  };
}
