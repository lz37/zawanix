{
  hostName,
  nixosHardwareModules,
}: {
  modulesPath,
  lib,
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
  inputs = asList (lib.attrByPath ["input"] [] hardware);
  touchpads =
    lib.filter (
      input: let
        baseClassName = lib.toLower (lib.attrByPath ["base_class" "name"] "" input);
        classList = map lib.toLower (asList (lib.attrByPath ["class_list"] [] input));
      in
        baseClassName == "touchpad" || lib.elem "touchpad" classList
    )
    inputs;
  chassisEntries = asList (lib.attrByPath ["chassis"] [] smbios);
  chassisTypeNames =
    map (
      entry: lib.toLower (lib.attrByPath ["chassis_type" "name"] "" entry)
    )
    chassisEntries;

  cardVendorName = card: lib.attrByPath ["vendor" "name"] null card;
  anyCardVendor = names: lib.any (card: lib.elem (cardVendorName card) names) graphicsCards;

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

  hasSolidStateDisk =
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

  hardwareImports =
    [
      nixosHardwareModules.common-pc
      (./hostname + "/${hostName}.nix")
      ./facter
      ./nvidia/gpu.nix
    ]
    ++ lib.optionals hasSolidStateDisk [
      nixosHardwareModules.common-pc-ssd
    ]
    ++ lib.optionals isLaptop [
      nixosHardwareModules.common-pc-laptop
    ]
    ++ lib.optionals (lib.attrByPath ["vendor_name"] null cpu == "GenuineIntel") [
      nixosHardwareModules.common-cpu-intel
    ]
    ++ lib.optionals (lib.attrByPath ["vendor_name"] null cpu == "AuthenticAMD") [
      nixosHardwareModules.common-cpu-amd
    ]
    ++ lib.optionals (anyCardVendor ["Intel Corporation"]) [
      nixosHardwareModules.common-gpu-intel
    ]
    ++ lib.optionals (anyCardVendor ["NVIDIA Corporation"]) [
      nixosHardwareModules.common-gpu-nvidia
    ]
    ++ lib.optionals
    (anyCardVendor [
      "Advanced Micro Devices, Inc. [AMD/ATI]"
      "Advanced Micro Devices, Inc."
    ])
    [
      nixosHardwareModules.common-gpu-amd
    ];
in {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ hardwareImports;
}
