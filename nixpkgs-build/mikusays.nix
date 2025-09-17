{
	fetchFromGitHub,
	rustPlatform,
	...
}: let
in
	rustPlatform.buildRustPackage (finalAttrs: rec {
			pname = "mikusays";
			version = "0.1.2";
			src =
				fetchFromGitHub {
					owner = "xxanqw";
					repo = pname;
					rev = "v${version}";
					sha256 = "sha256-snez998MU9giPx8N+2+d8QEAa9tSjxhE8UbwVrW57Vo=";
				};
			cargoHash = "sha256-AjEvXjFYCQ4dYQqBvphKI2AP+b1lGiO7ZrfRmK8rquw=";
		})
