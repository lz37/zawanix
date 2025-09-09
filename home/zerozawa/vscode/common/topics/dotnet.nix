{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		ms-dotnettools.csdevkit
		ms-dotnettools.vscodeintellicode-csharp
		ms-dotnettools.csharp
		ms-dotnettools.vscode-dotnet-runtime
	];
}
