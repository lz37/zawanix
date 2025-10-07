{
  fetchFromGitHub,
  rustPlatform,
  ...
}: let
in
  rustPlatform.buildRustPackage (finalAttrs: rec {
    pname = "mikusays";
    version = "0.1.3";
    src = fetchFromGitHub {
      owner = "xxanqw";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-KtYdnFOpWseRGm6zLeFfBYfI2IV2m8AaqcUTV7xgCeg=";
    };
    cargoHash = "sha256-B3kguD0kJPNfOz20nwrRG+TlovxNoXvUhCZV+CCRbdg=";
  })
