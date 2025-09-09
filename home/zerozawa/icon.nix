{pkgs, ...}: {
	xdg.dataFile = {
		"icons/Zafiro-Icons-Dark" = {
			source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Dark";
			force = true;
		};
		"icons/Zafiro-Icons-Light" = {
			source = "${pkgs.zafiro-icons}/share/icons/Zafiro-icons-Light";
			force = true;
		};
		"icons/MoreWaita" = {
			source = "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita";
		};
	};
}
