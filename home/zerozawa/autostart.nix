{pkgs, ...}: {
	xdg.autostart = {
		enable = true;
		readOnly = true;
		entries = with pkgs; [
			"${telegram-desktop_git}/share/applications/org.telegram.desktop.desktop"
			"${remmina}/share/applications/org.remmina.Remmina.desktop"
		];
	};
}
