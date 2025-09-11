{pkgs, ...}: {
	extensions = with pkgs.vscode-marketplace; [
		ms-ceintl.vscode-language-pack-zh-hans
	];
}
