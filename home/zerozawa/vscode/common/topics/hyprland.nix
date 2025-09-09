{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		fireblast.hyprlang-vscode
		ewen-lbh.vscode-hyprls
	];
}
