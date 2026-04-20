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
  cardDriver = card: lib.attrByPath ["driver"] null card;
  cardLabel = card: lib.attrByPath ["label"] null card;
  normalizedGraphicsCards =
    map (
      card: {
        vendor = normalizeGpuVendor (cardVendorName card);
        pciBusId = cardPciBusId card;
        driver = cardDriver card;
        label = cardLabel card;
      }
    )
    graphicsCards;
  normalizedVendorNames = map (card: card.vendor) normalizedGraphicsCards;
  duplicateGpuVendors = lib.unique (
    lib.filter (
      vendor: builtins.length (lib.filter (candidate: candidate == vendor) normalizedVendorNames) > 1
    )
    normalizedVendorNames
  );
  gpuCardCount = builtins.length normalizedGraphicsCards;
  normalizedVendorCount = vendor:
    builtins.length (lib.filter (card: card.vendor == vendor) normalizedGraphicsCards);
  nvidiaGpuCount = normalizedVendorCount "nvidia";
  nonNvidiaGpuCount = builtins.length (lib.filter (card: card.vendor != "nvidia") normalizedGraphicsCards);
  derivedGraphicsCards =
    map (
      card: let
        isOnboardVideo = card.label == "Onboard - Video";
        isSingleNvidiaHybrid = gpuCardCount > 1 && nvidiaGpuCount == 1;
        isHybridNonNvidiaCompanion = isSingleNvidiaHybrid && nonNvidiaGpuCount == 1 && card.vendor != "nvidia";
        role =
          if isOnboardVideo
          then "igpu"
          else if isSingleNvidiaHybrid && card.vendor == "nvidia"
          then "dgpu"
          else if isHybridNonNvidiaCompanion
          then "igpu"
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
        default = false;
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
        assertion = duplicateGpuVendors == [];
        message = "zerozawa.hardware.drm: duplicate GPU vendor(s) are unsupported: ${lib.concatStringsSep ", " duplicateGpuVendors}";
      }
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
              in
                device
                // {
                  role = role;
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
                  lib.optionals (matches != []) ["/dev/dri/${vendor}"]
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
      host.isGameMachine = false;
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
