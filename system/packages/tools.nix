{pkgs, ...}: {
	environment.systemPackages = with pkgs; [
		(fortune.override {
				withOffensive = true;
			})
		wakatime
		fd
		translate-shell
		tldr
		ventoy-full
		mikusays
	];
}
