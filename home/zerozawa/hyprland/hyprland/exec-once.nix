{
	stylixImage,
	lib,
	pkgs,
	...
}: let
	bg-kitty-conf =
		pkgs.writeText "bg-kitty-conf" ''
			font_family FiraCode Nerd Font Mono
			background_opacity 0.0
			font_size 12.0
			include ${pkgs.kitty-themes}/share/kitty-themes/themes/Monokai_Soda.conf
		'';
	bg-kitty-cava-sh =
		pkgs.writeScriptBin "bg-kitty-cava-sh" ''
			#!${lib.getExe pkgs.bash}
			${lib.getExe' pkgs.uutils-coreutils-noprefix "sleep"} 1 && ${lib.getExe pkgs.cava}
		'';
in {
	wayland.windowManager.hyprland.settings = {
		exec-once = [
			"wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store" # Saves text
			"wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store" # Saves images
			"dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
			"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
			# "systemctl --user start hyprpolkitagent"

			"killall -q swww;sleep .5 && swww-daemon"
			"killall -q waybar;sleep .5 && waybar"
			"killall -q swaync;sleep .5 && swaync"
			"#wallsetter &"
			"pypr &"
			"systemctl --user start plasma-polkit-agent.service"
			"${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
			"${lib.getExe' pkgs.kdePackages.polkit-kde-agent-1 "kwalletd6"} &"
			"${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator"
			"sleep 1.0 && swww img ${stylixImage}"
			''${lib.getExe pkgs.kitty} -c ${bg-kitty-conf} --class="kitty-bg" "${lib.getExe' bg-kitty-cava-sh "bg-kitty-cava-sh"}"''
			# (lib.getExe pkgs.fcitx5)
		];
	};
}
