args @ {
  hostName,
  nixosHardwareModules,
  ...
}: let
  bootstrap = {
    hostName,
    nixosHardwareModules,
  }: {
    lib,
    modulesPath,
    ...
  }: let
    report = builtins.fromJSON (builtins.readFile (./facter + "/${hostName}.json"));
    hardware = lib.attrByPath ["hardware"] {} report;
    smbios = lib.attrByPath ["smbios"] {} report;

    asList = value:
      if builtins.isList value
      then value
      else if value == null
      then []
      else [value];

    cpuEntries = asList (lib.attrByPath ["cpu"] [] hardware);
    cpu =
      if cpuEntries == []
      then {}
      else builtins.head cpuEntries;
    graphicsCards = asList (lib.attrByPath ["graphics_card"] [] hardware);
    disks = asList (lib.attrByPath ["disk"] [] hardware);
    chassisEntries = asList (lib.attrByPath ["chassis"] [] smbios);
    pointingInputs =
      (asList (lib.attrByPath ["input"] [] hardware))
      ++ (asList (lib.attrByPath ["mouse"] [] hardware));

    chassisTypeNames =
      map (
        entry: lib.toLower (lib.attrByPath ["chassis_type" "name"] "" entry)
      )
      chassisEntries;
    touchpads =
      lib.filter (
        input: let
          baseClassName = lib.toLower (lib.attrByPath ["base_class" "name"] "" input);
          classList = map lib.toLower (asList (lib.attrByPath ["class_list"] [] input));
        in
          baseClassName == "touchpad" || lib.elem "touchpad" classList
      )
      pointingInputs;

    cpuVendorName = lib.attrByPath ["vendor_name"] null cpu;
    hasCardVendor = names: lib.any (card: lib.elem (lib.attrByPath ["vendor" "name"] null card) names) graphicsCards;
    diskStrings = disk:
      map lib.toLower (
        (lib.filter builtins.isString [
          (lib.attrByPath ["sysfs_id"] null disk)
          (lib.attrByPath ["sysfs_bus_id"] null disk)
          (lib.attrByPath ["driver"] null disk)
          (lib.attrByPath ["driver_module"] null disk)
          (lib.attrByPath ["model"] null disk)
          (lib.attrByPath ["bus_type" "name"] null disk)
        ])
        ++ (lib.filter builtins.isString (asList (lib.attrByPath ["drivers"] [] disk)))
        ++ (lib.filter builtins.isString (asList (lib.attrByPath ["driver_modules"] [] disk)))
        ++ (lib.filter builtins.isString (asList (lib.attrByPath ["unix_device_names"] [] disk)))
      );

    isIntelCPU = cpuVendorName == "GenuineIntel";
    isAMDCPU = cpuVendorName == "AuthenticAMD";
    isIntelGPU = hasCardVendor ["Intel Corporation"];
    isAmdGPU = hasCardVendor [
      "Advanced Micro Devices, Inc. [AMD/ATI]"
      "ATI Technologies Inc"
      "AMD"
    ];
    isNvidiaGPU = hasCardVendor ["nVidia Corporation"];
    isLaptop =
      lib.any (
        name:
          lib.elem name [
            "laptop"
            "notebook"
            "convertible"
            "portable"
            "tablet"
            "slim notebook"
          ]
      )
      chassisTypeNames
      || touchpads != [];
    isSSD =
      lib.any (
        disk:
          lib.any (
            text:
              lib.any (needle: lib.hasInfix needle text) [
                "nvme"
                "ssd"
                "solid state"
              ]
          ) (diskStrings disk)
      )
      disks;

    nixosHardwareImports =
      (lib.optionals isIntelCPU [nixosHardwareModules.common-cpu-intel])
      ++ (lib.optionals isAMDCPU [nixosHardwareModules.common-cpu-amd])
      ++ (lib.optionals isIntelGPU [nixosHardwareModules.common-gpu-intel])
      ++ (lib.optionals isAmdGPU [nixosHardwareModules.common-gpu-amd])
      ++ (lib.optionals isNvidiaGPU [nixosHardwareModules.common-gpu-nvidia])
      ++ (lib.optionals isLaptop [nixosHardwareModules.common-pc-laptop])
      ++ (lib.optionals (!isLaptop) [nixosHardwareModules.common-pc])
      ++ (lib.optionals isSSD [nixosHardwareModules.common-pc-ssd]);
  in {
    imports =
      [
        (modulesPath + "/installer/scan/not-detected.nix")
        ./facter
      ]
      ++ nixosHardwareImports
      ++ [
        (./. + "/hostname/${hostName}.nix")
      ]
      ++ (lib.optionals isNvidiaGPU [./nvidia/gpu.nix]);
  };
in
  if args ? lib || args ? modulesPath
  then
    bootstrap {
      inherit hostName nixosHardwareModules;
    }
    args
  else
    bootstrap {
      inherit hostName nixosHardwareModules;
    }
