{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		tamasfe.even-better-toml
	];
	settings = {
		"[toml]" = {
			"editor.defaultFormatter" = "tamasfe.even-better-toml";
		};
	};
}
