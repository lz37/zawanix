{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		ms-kubernetes-tools.vscode-kubernetes-tools
	];
	settings = {
		"vs-kubernetes" = {
			"vs-kubernetes.crd-code-completion" = "enabled";
		};
	};
}
