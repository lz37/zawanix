{pkgs, ...}: {
	services.scx = {
		enable = true;
		package = pkgs.master.scx.full;
		scheduler = "scx_rusty";
	};
}
