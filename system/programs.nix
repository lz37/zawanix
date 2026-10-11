{
  pkgs,
  lib,
  config,
  ...
}: let
  hostName = config.networking.hostName;
  hw = config.zerozawa.hardware;
  host = config.zerozawa.host;
  cachyosProton =
    if lib.versionAtLeast (lib.strings.substring 8 1 hw.amd64Microarchs) "3"
    then pkgs.nur.repos.forkprince.proton-cachyos-v3-bin
    else pkgs.nur.repos.forkprince.proton-cachyos-v1-bin;
  # proton-cachyos 的默认 out 输出是 120 字节的哨兵文本（"should not be installed into
  # environments"），不是目录，pkgs.buildEnv 合并非目录 store path 会直接失败，所以绝不能进
  # environment.systemPackages。真正的 Proton 工具树在 steamcompattool 输出里（nixos 的
  # steam 模块用的也是这个输出）。
  cachyosProtonDir = lib.getOutput "steamcompattool" cachyosProton;
in {
  environment.systemPackages = [
    # 固定路径 /run/current-system/sw/share/proton-cachyos，给 Steam 之外的启动器用。
    # 不能放 /etc：umu-run / Lutris 等 FHS 沙箱包装器把 /etc 换成 tmpfs + 白名单，
    # 宿主 /etc 下的新条目在沙箱里看不见；而 /run /opt 这类顶层目录会被 bind 进屋。
    (pkgs.runCommandLocal "proton-cachyos" {} ''
      mkdir -p $out/share
      ln -s ${cachyosProtonDir} $out/share/proton-cachyos
    '')
  ];
  programs = {
    dms-greeter = {
      enable = true;
      compositor.name = "hyprland"; # Or "hyprland" or "sway"
      configHome = config.zerozawa.path.home;
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
    nix-index-database.comma.enable = true;
    gamemode = {
      enable = host.isGameMachine;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu =
          {
            apply_gpu_optimisations = "accept-responsibility";
          }
          // (
            if hw.isNvidiaGPU
            then {
              nv_powermizer_mode = 1;
            }
            else if hw.isAmdGPU
            then {
              amd_performance_level = "high";
            }
            else {}
          )
          // {
            gpu_device =
              # 主gpu
              (
                {
                  zawanix-fubuki = 2;
                  zawanix-glap = 1;
                  zawanix-thinkbook = 0;
                }
              .${
                  hostName
                } or 0
              );
          };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
    # 鼠标自动化
    ydotool.enable = true;
    nixos-cli = {
      enable = true;
    };
    gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;
    # steam
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extest.enable = true;
      # cachyos-proton 仅发布 v1/v3/arm 变体（arm 用不到），按本机 microarch 就近选择
      extraCompatPackages = [
        cachyosProton
      ];
      protontricks = {
        enable = true;
      };
    };
    # solve GTK themes are not applied in Wayland applications
    dconf.enable = true;
    # needed for `nix-alien-ld`
    nix-ld.enable = true;
    kdeconnect = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
    };
    virt-manager = {
      enable = true;
    };
    command-not-found.enable = false;
    bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    zsh = {
      enable = true;
      interactiveShellInit = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = config.zerozawa.path.cfgRoot;
    };
    mtr.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: (with pkgs; [
          libatomic_ops
          bzip2
        ]);
      };
    };
  };
}
