{
  lib,
  config,
  ...
}: let
  mkOptionType = type:
    lib.mkOption {
      inherit type;
    };
  bool = mkOptionType lib.types.bool;
  int = mkOptionType lib.types.int;
  str = mkOptionType lib.types.str;

  report = lib.attrByPath ["hardware" "facter" "report"] {} config;
  facter = import ../common/facter-derived.nix {
    inherit lib report;
  };
  inherit
    (facter)
    graphicsCards
    cardVendorName
    ;
  hardwareFlags = facter.flags;
  normalizeHex = value:
    if builtins.isString value
    then lib.toLower value
    else null;
  identityPart = value:
    if value == null
    then "unknown"
    else value;
  normalizeGpuVendor = vendorName:
    if vendorName == null
    then throw "zerozawa.hardware.drm: unsupported GPU vendor: null"
    else if vendorName == "Intel Corporation"
    then "intel"
    else if vendorName == "nVidia Corporation"
    then "nvidia"
    else if
      lib.elem vendorName [
        "ATI Technologies Inc"
        "AMD"
        "Advanced Micro Devices, Inc. [AMD/ATI]"
      ]
    then "amd"
    else throw "zerozawa.hardware.drm: unsupported GPU vendor '${vendorName}'";
  cardPciBusId = card: lib.attrByPath ["sysfs_bus_id"] null card;
  cardDeviceHex = card: normalizeHex (lib.attrByPath ["device" "hex"] null card);
  cardSubVendorHex = card: normalizeHex (lib.attrByPath ["sub_vendor" "hex"] null card);
  cardSubDeviceHex = card: normalizeHex (lib.attrByPath ["sub_device" "hex"] null card);
  cardDriver = card: lib.attrByPath ["driver"] null card;
  cardLabel = card: lib.attrByPath ["label"] null card;
  cardSlotBus = card: lib.attrByPath ["slot" "bus"] null card;
  cardAttachedTo = card: lib.attrByPath ["attached_to"] null card;
  cardModuleAlias = card: lib.attrByPath ["module_alias"] null card;
  cardBaseClassHex = card: normalizeHex (lib.attrByPath ["base_class" "hex"] null card);
  cardSubClassHex = card: normalizeHex (lib.attrByPath ["sub_class" "hex"] null card);
  gpuRoleOverrides = {
    "amd:13c0:1043:8877" = "igpu";
  };
  normalizedGraphicsCards =
    map (
      card: let
        vendor = normalizeGpuVendor (cardVendorName card);
        deviceHex = cardDeviceHex card;
        subVendorHex = cardSubVendorHex card;
        subDeviceHex = cardSubDeviceHex card;
      in {
        inherit
          vendor
          deviceHex
          subVendorHex
          subDeviceHex
          ;
        pciBusId = cardPciBusId card;
        driver = cardDriver card;
        label = cardLabel card;
        slotBus = cardSlotBus card;
        attachedTo = cardAttachedTo card;
        moduleAlias = cardModuleAlias card;
        baseClassHex = cardBaseClassHex card;
        subClassHex = cardSubClassHex card;
        identityKey = lib.concatStringsSep ":" [
          vendor
          (identityPart deviceHex)
          (identityPart subVendorHex)
          (identityPart subDeviceHex)
        ];
      }
    )
    graphicsCards;
  derivedGraphicsCards =
    map (
      card: let
        overriddenRole = gpuRoleOverrides.${card.identityKey} or null;
        role =
          if overriddenRole != null
          then overriddenRole
          else if card.label == "Onboard - Video"
          then "igpu"
          else if card.vendor == "nvidia"
          then "dgpu"
          else null;
      in
        card
        // {
          inherit role;
        }
    )
    normalizedGraphicsCards;
  roleCount = role: builtins.length (lib.filter (card: card.role == role) derivedGraphicsCards);
  igpuCount = roleCount "igpu";
  dgpuCount = roleCount "dgpu";
in {
  options = {
    zerozawa = {
      hardware = {
        isNvidiaGPU = bool;
        isIntelGPU = bool;
        isIntelCPU = bool;
        isAMDCPU = bool;
        isAmdGPU = bool;
        isLaptop = bool;
        isSSD = bool;
        ram = int;
        amd64Microarchs = str;
        drm = {
          devices = lib.mkOption {
            default = [];
            type = lib.types.listOf lib.types.attrs;
          };
          aqDrmDevices = lib.mkOption {
            default = "";
            type = lib.types.str;
          };
        };
      };
      host.isGameMachine = lib.mkOption {
        type = lib.types.bool;
        default = dgpuCount > 0;
      };
      github = {
        access-token = {
          pat = str;
          classic = str;
        };
      };
      context7.apiKey = str;
      exa-mcp.apiKey = str;
      bailian-coding-plan.apiKey = str;
      zerotier = {
        id = str;
      };
      path = {
        cfgRoot = str;
        profile = str;
        p10k = str;
        home = str;
        code = str;
        public = str;
        downloads = str;
        private = str;
        mihomoCfg = str;
        kitty = str;
      };
      users.zerozawa.uid = mkOptionType lib.types.int;
      network = {
        static-address = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
      atuin = {
        server = str;
      };
      navidrome = {
        url = str;
        username = str;
        password = str;
      };
      servers = {
        openwrt = {
          address = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
        teleport = {
          address = str;
          port = mkOptionType lib.types.int;
        };
      };
      git = {
        userName = str;
        userEmail = str;
      };
      ssh = {
        machines = lib.mkOption {
          default = [];
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                host = str;
                port = lib.mkOption {
                  type = lib.types.nullOr lib.types.int;
                  default = null;
                };
                user = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                proxyJump = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                type = mkOptionType (
                  lib.types.enum [
                    "linux"
                    "macOS"
                    "windows"
                  ]
                );
              };
            }
          );
        };
      };
      vscode = {
        sherlock.userId = str;
      };
      mihomo = {
        subscribe = str;
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = igpuCount <= 1;
        message = "zerozawa.hardware.drm: expected at most one dynamically derived igpu, found ${toString igpuCount}";
      }
      {
        assertion = dgpuCount <= 1;
        message = "zerozawa.hardware.drm: expected at most one dynamically derived dgpu, found ${toString dgpuCount}";
      }
    ];
    zerozawa = {
      hardware = {
        inherit
          (hardwareFlags)
          isNvidiaGPU
          isIntelGPU
          isIntelCPU
          isAMDCPU
          isAmdGPU
          isLaptop
          isSSD
          ram
          amd64Microarchs
          ;
        drm = let
          vendorCount = vendor:
            builtins.length (lib.filter (device: device.vendor == vendor) derivedGraphicsCards);
          devices =
            map (
              device: let
                role = device.role;
                vendorAlias = lib.optionals (vendorCount device.vendor == 1) [device.vendor];
                roleAlias = lib.optionals (role != null) [role];
              in {
                inherit
                  (device)
                  vendor
                  pciBusId
                  driver
                  label
                  role
                  ;
                symlinkNames = vendorAlias ++ roleAlias;
              }
            )
            derivedGraphicsCards;
          hasIgpu = builtins.any (device: lib.elem "igpu" device.symlinkNames) devices;
          hasDgpu = builtins.any (device: lib.elem "dgpu" device.symlinkNames) devices;
          vendorPaths = lib.concatStringsSep ":" (
            lib.concatLists (
              map (
                vendor: let
                  matches = lib.filter (device: device.vendor == vendor && device.role == null) devices;
                in
                  lib.optionals (vendorCount vendor == 1 && matches != []) ["/dev/dri/${vendor}"]
              ) ["intel" "amd" "nvidia"]
            )
          );
        in {
          devices = devices;
          aqDrmDevices = lib.concatStringsSep ":" (
            if hasIgpu
            then lib.optionals true ["/dev/dri/igpu"] ++ lib.optionals hasDgpu ["/dev/dri/dgpu"]
            else
              (
                if vendorPaths == ""
                then []
                else lib.splitString ":" vendorPaths
              )
              ++ lib.optionals hasDgpu ["/dev/dri/dgpu"]
          );
        };
      };
      path = rec {
        cfgRoot = "/etc/nixos";
        profile = "${cfgRoot}/profile";
        p10k = "${profile}/.p10k.zsh";
        home = "/home/zerozawa";
        code = "${home}/code";
        public = "${home}/Public";
        downloads = "${home}/Downloads";
        private = "${cfgRoot}/private";
        mihomoCfg = "${profile}/mihomo.yaml";
        kitty = "${profile}/kitty.conf";
      };
      users = {
        zerozawa = {
          uid = 1000;
        };
      };
    };
  };
}
