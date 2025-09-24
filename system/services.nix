{pkgs, ...}: {
	services = {
		printing = {
			enable = true;
			drivers = with pkgs; [
				gutenprint
				hplip
				splix
			];
		};
		glances = {
			enable = true;
			openFirewall = true;
		};
		avahi = {
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
		};
		ipp-usb.enable = true;
		udisks2.enable = true;
		fwupd.enable = true;
		dbus = {
			apparmor = "disabled";
			implementation = "broker";
		};
		desktopManager.plasma6 = {
			enable = true;
			enableQt5Integration = true;
		};
		spice-vdagentd.enable = true;
		xserver = {
			enable = true;
			xkb = {
				layout = "cn";
				variant = "";
			};
		};
		openssh = {
			enable = true;
			openFirewall = true;
			settings = {
				GatewayPorts = "yes";
				PermitRootLogin = "no";
				X11Forwarding = true;
			};
			allowSFTP = true;
			extraConfig = ''
				AllowTcpForwarding yes
				TCPKeepAlive yes
			'';
		};
		nixos-cli = {
			enable = true;
		};
	};
}
