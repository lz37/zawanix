{
  lib,
  report,
}: let
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
  memoryDevices = asList (lib.attrByPath ["memory_device"] [] smbios);
  cpuFeatures = map lib.toLower (asList (lib.attrByPath ["features"] [] cpu));
  cpuVendorName = lib.attrByPath ["vendor_name"] null cpu;
  hasFeature = feature: lib.elem feature cpuFeatures;
  hasAllFeatures = features: lib.all hasFeature features;

  cardVendorName = card: lib.attrByPath ["vendor" "name"] null card;
  vendorNames = {
    intel = ["Intel Corporation"];
    nvidia = ["nVidia Corporation"];
    amd = [
      "Advanced Micro Devices, Inc. [AMD/ATI]"
      "ATI Technologies Inc"
      "AMD"
    ];
  };
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
    || (builtins.length touchpads > 0);

  memoryBytes =
    builtins.foldl' (
      sum: entry:
        sum
        + builtins.foldl' (
          entrySum: resource:
            if (lib.attrByPath ["type"] "" resource) == "phys_mem"
            then entrySum + (lib.attrByPath ["range"] 0 resource)
            else entrySum
        )
        0 (asList (lib.attrByPath ["resources"] [] entry))
    )
    0 (asList (lib.attrByPath ["memory"] [] hardware));
  memoryDeviceKiB =
    builtins.foldl' (
      sum: device: let
        size = lib.attrByPath ["size"] 0 device;
      in
        if builtins.isInt size && size > 0
        then sum + size
        else sum
    )
    0
    memoryDevices;
  rawMemoryMiB = builtins.div memoryBytes (1024 * 1024);
  installedMemoryMiB =
    if memoryDeviceKiB > 0
    then builtins.div memoryDeviceKiB 1024
    else rawMemoryMiB;

  microarch =
    if
      hasAllFeatures [
        "ssse3"
        "sse4_1"
        "sse4_2"
        "popcnt"
        "cx16"
        "lahf_lm"
        "avx"
        "avx2"
        "bmi1"
        "bmi2"
        "f16c"
        "fma"
        "movbe"
        "avx512f"
        "avx512bw"
        "avx512cd"
        "avx512dq"
        "avx512vl"
      ]
    then "x86_64_v4"
    else if
      hasAllFeatures [
        "ssse3"
        "sse4_1"
        "sse4_2"
        "popcnt"
        "cx16"
        "lahf_lm"
        "avx"
        "avx2"
        "bmi1"
        "bmi2"
        "f16c"
        "fma"
        "movbe"
      ]
    then "x86_64_v3"
    else if
      hasAllFeatures [
        "ssse3"
        "sse4_1"
        "sse4_2"
        "popcnt"
        "cx16"
        "lahf_lm"
      ]
    then "x86_64_v2"
    else "x86_64_v1";
in {
  inherit
    asList
    hardware
    smbios
    cpuEntries
    cpu
    graphicsCards
    disks
    inputs
    touchpads
    chassisEntries
    chassisTypeNames
    memoryDevices
    cpuFeatures
    cpuVendorName
    cardVendorName
    anyCardVendor
    diskStrings
    hasSolidStateDisk
    installedMemoryMiB
    microarch
    vendorNames
    ;

  flags = {
    isNvidiaGPU = anyCardVendor vendorNames.nvidia;
    isIntelGPU = anyCardVendor vendorNames.intel;
    isIntelCPU = cpuVendorName == "GenuineIntel";
    isAMDCPU = cpuVendorName == "AuthenticAMD";
    isAmdGPU = anyCardVendor vendorNames.amd;
    inherit isLaptop;
    isSSD = hasSolidStateDisk;
    ram = installedMemoryMiB;
    amd64Microarchs = microarch;
  };
}
