{ ram, pkgs, ... }:
let
  makeTrue =
    v:
    v
    |> builtins.map (x: {
      name = x;
      value = true;
    })
    |> builtins.listToAttrs;
in
{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    dbaeumer.vscode-eslint
    stylelint.vscode-stylelint
    formulahendry.auto-rename-tag
    formulahendry.auto-close-tag
    yoavbls.pretty-ts-errors
    typescriptteam.native-preview
  ];
  settings = {
    "typescript.tsserver.maxTsServerMemory" = ram / 4;
    "typescript.updateImportsOnFileMove.enabled" = "always";
    "javascript.updateImportsOnFileMove.enabled" = "always";
    # "typescript.experimental.useTsgo" = true;
    "typescript.inlayHints.parameterNames.enabled" = "all";
  }
  // (makeTrue [
    "typescript.experimental.expandableHover"
    "typescript.tsserver.experimental.enableProjectDiagnostics"
    "typescript.implementationsCodeLens.enabled"
    "typescript.implementationsCodeLens.showOnInterfaceMethods"
    "typescript.referencesCodeLens.enabled"
    "typescript.referencesCodeLens.showOnAllFunctions"
    "typescript.enablePromptUseWorkspaceTsdk"
    "typescript.inlayHints.enumMemberValues.enabled"
    "typescript.inlayHints.parameterNames.suppressWhenArgumentMatchesName"
    "typescript.inlayHints.parameterTypes.enabled"
    "typescript.inlayHints.functionLikeReturnTypes.enabled"
    "typescript.inlayHints.propertyDeclarationTypes.enabled"
    "typescript.inlayHints.variableTypes.enabled"
    "typescript.inlayHints.variableTypes.suppressWhenTypeMatchesName"
    "typescript.suggest.autoImports"
    "typescript.suggest.classMemberSnippets.enabled"
    "typescript.suggest.completeFunctionCalls"
    "typescript.suggest.completeJSDocs"
    "typescript.suggest.enabled"
    "typescript.suggest.includeAutomaticOptionalChainCompletions"
    "typescript.suggest.jsdoc.generateReturns"
    "typescript.suggest.paths"
    "typescript.suggest.includeCompletionsForImportStatements"
    "typescript.suggest.objectLiteralMethodSnippets.enabled"
    "typescript.suggestionActions.enabled"
  ]);
}
