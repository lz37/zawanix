{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		github.vscode-github-actions
		gitlab.gitlab-workflow
	];
}
