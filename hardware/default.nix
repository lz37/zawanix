{
  modulesPath,
  lib,
  inputs,
  hostName,
  ...
}:
let
  report = builtins.fromJSON (builtins.readFile (./facter + "/${hostName}.json"));
  facter = import ../common/facter-derived.nix {
    inherit lib report;
  };
  hw = facter.flags;

  hardwareImports = [
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
    # common-cpu-amd-pstate 已移除：nixpkgs 的 nixos-facter 模块
    # （nixos/modules/hardware/facter/amd-cpu.nix，由 ./facter 的 reportPath 启用）
    # 已经对 AMD CPU 设置 amd_pstate=active，再导入一次会让内核 cmdline
    # 出现两条相同的 amd_pstate=active。
    # zenpower 移除（2026-09）：树外模块随内核升级反复断编译，
    # k10temp 自 5.11 起已覆盖电压/电流/功率遥测。
    {
      boot.kernelModules = [ "k10temp" ];
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
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ]
  ++ hardwareImports;
  hardware = {
    xpadneo.enable = true;
    xone.enable = true;
  };
}
