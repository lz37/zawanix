{pkgs, ...}: {
	extensions =
		pkgs.vscode-selected-extensionsCompatible-nix4vscode.forVscodePrerelease [
			"ms-ceintl.vscode-language-pack-zh-hans"
		];
}
