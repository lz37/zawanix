{config, ...}: {
	services = {
		mpris-proxy.enable = true;
	};
	stylix.targets.fish.enable = true;
	programs = {
		nix-search-tv = {
			enable = true;
			enableTelevisionIntegration = true;
			settings = {
				indexes = [
					"nixpkgs"
					"home-manager"
					"nixos"
					"nur"
				];
				experimental = {
					render_docs_indexes = {
						nvf = "https://notashelf.github.io/nvf/options.html";
						plasma-manager = "https://nix-community.github.io/plasma-manager/options.xhtml";
					};
				};
			};
		};
		television = {
			enable = true;
			enableZshIntegration = true;
			enableBashIntegration = true;
		};
		gh.enable = true;
		pay-respects = {
			enable = true;
			enableZshIntegration = true;
			options = [
				"--alias"
				"fk"
			];
		};
		bash.enable = true;
		fish = {
			enable = true;
		};
		command-not-found.enable = false;
		atuin = {
			enable = true;
			enableZshIntegration = true;
			settings = {
				auto_sync = true;
				sync_frequency = "5m";
				sync_address = config.zerozawa.atuin.server;
				search_mode = "prefix";
			};
		};
		direnv = {
			enable = true;
			enableZshIntegration = true;
			config = {
				whitelist.prefix = [config.zerozawa.path.code];
			};
			nix-direnv.enable = true;
		};
		ripgrep-all = {
			enable = true;
		};
		ripgrep = {
			enable = true;
		};
	};
}
