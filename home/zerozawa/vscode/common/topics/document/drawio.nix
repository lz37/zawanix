{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		hediet.vscode-drawio
	];
	settings = {
		"hediet.vscode-drawio.resizeImages" = true;
	};
}
