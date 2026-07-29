{
  pkgs,
  osConfig,
  ...
}: let
  hw = osConfig.zerozawa.hardware;
  makeTrue = v:
    v
    |> map (x: {
      name = x;
      value = true;
    })
    |> builtins.listToAttrs;
in {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    dbaeumer.vscode-eslint
    stylelint.vscode-stylelint
    formulahendry.auto-rename-tag
    formulahendry.auto-close-tag
    yoavbls.pretty-ts-errors
    typescriptteam.native-preview
    # oxc.oxc-vscode
    vitest.explorer
  ];
  settings =
    {
      "js/ts.tsserver.maxTsServerMemory" = hw.ram / 4;
      "js/ts.updateImportsOnFileMove.enabled" = "always";
      # "typescript.experimental.useTsgo" = true;
      "js/ts.inlayHints.parameterNames.enabled" = "all";
    }
    // (makeTrue [
      "js/ts.experimental.expandableHover"
      "js/ts.tsserver.experimental.enableProjectDiagnostics"
      "js/ts.implementationsCodeLens.enabled"
      "js/ts.implementationsCodeLens.showOnInterfaceMethods"
      "js/ts.referencesCodeLens.enabled"
      "js/ts.referencesCodeLens.showOnAllFunctions"
      "js/ts.enablePromptUseWorkspaceTsdk"
      "js/ts.inlayHints.enumMemberValues.enabled"
      "js/ts.inlayHints.parameterNames.suppressWhenArgumentMatchesName"
      "js/ts.inlayHints.parameterTypes.enabled"
      "js/ts.inlayHints.functionLikeReturnTypes.enabled"
      "js/ts.inlayHints.propertyDeclarationTypes.enabled"
      "js/ts.inlayHints.variableTypes.enabled"
      "js/ts.inlayHints.variableTypes.suppressWhenTypeMatchesName"
      "js/ts.suggest.autoImports"
      "js/ts.suggest.classMemberSnippets.enabled"
      "js/ts.suggest.completeFunctionCalls"
      "js/ts.suggest.completeJSDocs"
      "js/ts.suggest.enabled"
      "js/ts.suggest.includeAutomaticOptionalChainCompletions"
      "js/ts.suggest.jsdoc.generateReturns"
      "js/ts.suggest.paths"
      "js/ts.suggest.includeCompletionsForImportStatements"
      "js/ts.suggest.objectLiteralMethodSnippets.enabled"
      "js/ts.suggestionActions.enabled"
    ]);
}
