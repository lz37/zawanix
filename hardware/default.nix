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
      # zenpower 移除（2026-09）：树外模块随内核升级反复断编译，
      # k10temp 自 5.11 起已覆盖电压/电流/功率遥测。
      {
        boot.kernelModules = ["k10temp"];
      }
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
