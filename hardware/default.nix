{
  modulesPath,
  hostName,
  isIntelCPU,
  isNvidiaGPU,
  lib,
  ...
}:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ [
      (./. + "/hostname/${hostName}.nix")
    ]
    ++ (lib.optionals isIntelCPU [ ./intel/cpu.nix ])
    ++ (lib.optionals isNvidiaGPU [ ./nvidia/gpu.nix ]);
}
