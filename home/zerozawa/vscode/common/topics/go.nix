{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		golang.go
	];
	settings = {
		"go.toolsManagement.autoUpdate" = true;
	};
}
