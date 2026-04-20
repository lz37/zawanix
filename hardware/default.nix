{
  modulesPath,
  lib,
  inputs,
  hostName,
  ...
}: let
  report = builtins.fromJSON (builtins.readFile (./facter + "/${hostName}.json"));
  facter = import ../common/facter-derived.nix {
    inherit lib report;
  };
  hw = facter.flags;

  hardwareImports =
    [
      inputs.nixos-hardware.nixosModules.common-pc
      (./hostname + "/${hostName}.nix")
      ./facter
      ./nvidia/gpu.nix
    ]
    ++ lib.optionals hw.isSSD [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ]
    ++ lib.optionals hw.isLaptop [
      inputs.nixos-hardware.nixosModules.common-pc-laptop
    ]
    ++ lib.optionals hw.isIntelCPU [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
    ]
    ++ lib.optionals hw.isAMDCPU [
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    ]
    ++ lib.optionals hw.isIntelGPU [
      inputs.nixos-hardware.nixosModules.common-gpu-intel
    ]
    ++ lib.optionals hw.isNvidiaGPU [
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    ]
    ++ lib.optionals hw.isAmdGPU [
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];
in {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ hardwareImports;
}
