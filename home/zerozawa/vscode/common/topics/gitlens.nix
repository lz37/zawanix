{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		eamodio.gitlens
	];
	settings = {
		"gitlens.launchpad.indicator.enabled" = false;
	};
}
