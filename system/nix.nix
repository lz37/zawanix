{
	inputs,
	lib,
	...
}: {
	nix = {
		# for nixd
		nixPath = ["nixpkgs=${inputs.nixpkgs}"];
		settings = {
			# 实验性功能
			experimental-features = [
				"nix-command"
				"flakes"
				"pipe-operators"
			];
			substituters =
				lib.mkForce [
					# 上交
					"https://mirror.sjtu.edu.cn/nix-channels/store?priority=10"
					# 中科大
					"https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
					# 中科院
					"https://mirror.iscas.ac.cn/nix-channels/store?priority=10"
					# 清华
					"https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=11"
					# 南大
					"https://mirror.nju.edu.cn/nix-channels/store?priority=11"
					# 北外
					# "https://mirrors.bfsu.edu.cn/nix-channels/store?priority=11"
					# 重庆邮电
					# "https://mirrors.cqupt.edu.cn/nix-channels/store?priority=12"

					# 回退
					"https://cache.nixos.org"

					"https://nix-community.cachix.org"
					"https://hyprland.cachix.org"
					# "https://winapps.cachix.org/"
					"https://nix-gaming.cachix.org"
					"https://nixpkgs-wayland.cachix.org"
					"https://watersucks.cachix.org"
					"https://numtide.cachix.org"
				];
			trusted-public-keys = [
				"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
				"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
				# "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="za
				"nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
				"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
				"watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
				"numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
			];
			trusted-users = [
				"zerozawa"
			];
		};
		# gc
		gc = {
			# programs.nh.clean.enable and nix.gc.automatic are both enabled. Please use one or the other to avoid conflict.
			automatic = false;
			dates = "03:00";
			options = "--delete-older-than 5d";
		};
		optimise = {
			automatic = true;
			dates = ["03:45"];
		};
	};
}
