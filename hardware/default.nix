{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./facter
    ./hostname/zawanix-work.nix
    ./hostname/zawanix-glap.nix
    ./hostname/zawanix-fubuki.nix
    ./nvidia/gpu.nix
  ];
}
