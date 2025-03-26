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
      (
        {
          "zawanix-work" = ./hostname/zawanix-work.nix;
          "zawanix-glap" = ./hostname/zawanix-glap.nix;
        }
        ."${hostName}"
      )
    ]
    ++ (lib.optionals isIntelCPU [ ./intel/cpu.nix ])
    ++ (lib.optionals isNvidiaGPU [ ./nvidia/gpu.nix ]);
}
