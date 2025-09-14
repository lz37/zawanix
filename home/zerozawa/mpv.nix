{pkgs, ...}: {
	stylix.targets.mpv.enable = true;
	programs.mpv = {
		enable = true;
		scripts = with pkgs.mpvScripts; [
			mpris
			modernx
			memo
			mpv-notify-send
		];
		config = {
			autoload-files = "yes";
			profile = "high-quality";
			vo = "gpu-next";
			target-colorspace-hint = "yes";
			gpu-api = "vulkan";
			gpu-context = "waylandvk";
		};
	};
}
