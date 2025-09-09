{hostName, ...}: {
	virtualisation = {
		oci-containers = {
			backend = "docker";
			containers =
				{}
				// (
					if hostName == "zawanix-work"
					then {
						ddns-go = {
							hostname = "ddns-go";
							image = "ghcr.io/jeessy2/ddns-go:latest";
							volumes = [
								"ddns_go:/root"
							];
							extraOptions = [
								"--network=host"
							];
							cmd = [
								"-l"
								":9877"
								"-f"
								"600"
							];
						};
					}
					else {}
				);
		};
	};
}
