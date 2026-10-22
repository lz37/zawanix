moduleArgs @ {
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
(
  {osConfig ? null, ...}: let
    systemConfig =
      if osConfig != null
      then osConfig
      else config;
    hw = systemConfig.zerozawa.hardware;
    system = pkgs.stdenv.hostPlatform.system;
    nixpkgsConfig = {
      allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
      allowUnfree = true;
      cudaSupport = hw.isNvidiaGPU;
      rocmSupport = hw.isAmdGPU;
    };
  in {
    nixpkgs = {
      config = nixpkgsConfig;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
        inputs.nix-alien.overlays.default
        inputs.nix4vscode.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.llm-agents.overlays.shared-nixpkgs
        # inputs.hyprland.overlays.default
        # inputs.hyprland.overlays.hyprland-packages
        (
          final: prev: let
            pkgs = prev;
          in rec {
            # 启用 NUR
            nur = import inputs.nur {
              nurpkgs = prev;
              pkgs = prev;
              repoOverrides = {
                zerozawa = import inputs.zerozawa-nur {inherit pkgs;};
              };
            };
            stable = import inputs.nixpkgs-stable {
              inherit system;
              config = nixpkgsConfig;
            };
            master = import inputs.nixpkgs-master {
              inherit system;
              config = nixpkgsConfig;
            };
            nogpu = import inputs.nixpkgs {
              inherit system;
              config =
                nixpkgsConfig
                // {
                  cudaSupport = false;
                  rocmSupport = false;
                };
              overlays = [
                (final: prev: {
                  nur = import inputs.nur {
                    nurpkgs = prev;
                    pkgs = prev;
                  };
                })
              ];
            };
            vscode-selected = master.vscode.override {
              # commandLineArgs = "--disable-features=WaylandWpColorManagerV1";
            };
            vscode-selected-extensionsCompatible =
              ((pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected))
              // {
                forVscode = pkgs.nix4vscode.forVscodeVersion (lib.getVersion vscode-selected);
                forVscodePrerelease = pkgs.nix4vscode.forVscodeVersionPrerelease (lib.getVersion vscode-selected);
                forOpenVsx = pkgs.nix4vscode.forOpenVsxVersion (lib.getVersion vscode-selected);
                forOpenVsxPrerelease = pkgs.nix4vscode.forOpenVsxVersionPrerelease (lib.getVersion vscode-selected);
              };
            intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
            nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
            quickshell = inputs.quickshell.packages.${system}.quickshell.withModules (
              with pkgs.kdePackages; [
                kirigami
                kirigami-addons
                kirigami-gallery
              ]
            );
            # apm 0.34.0 的 METADATA 钉了 websockets<17，但代码只用 websockets.sync.client
            #（17 仍保留该 API），nixpkgs 已提供 17.0.1。
            llm-agents =
              prev.llm-agents
              // {
                apm = prev.llm-agents.apm.overrideAttrs (oa: {
                  pythonRelaxDeps = (oa.pythonRelaxDeps or []) ++ ["websockets"];
                });
              };
            # deal 的测试 import docstring_parser.tests，而 docstring-parser 0.18.0 的包
            # 剔除了 tests 目录 → pytest 收集期报错（依赖链 nix-alien → pylddwrap → icontract）。
            # nix-alien 的 overlay 用 `pkgs = prev` 独立求值，改全局 python3Packages 到不了它，
            # 只能直接替换它的 python3。
            nix-alien = prev.nix-alien.override {
              python3 = prev.python3.override {
                packageOverrides = pfinal: pprev: {
                  # deal 的测试套件在新工具链下已不可用：收集期 import
                  # docstring_parser.tests（该包剔除了 tests 目录）、typeguard 4 移除
                  # CallMemo、test_offline 需要访问 httpbin.org（沙箱无网）。
                  deal = pprev.deal.overridePythonAttrs (_: {
                    doCheck = false;
                  });
                };
              };
            };
            # khal 的 sphinxBuilders 是 list，structuredAttrs 下会变成 bash 数组，
            # sphinxHook 的 `eval "__sphinxBuilders=($sphinxBuilders)"` 因此只取到 "html"，
            # man 输出从未生成。传成空格分隔的字符串。
            khal = prev.khal.overrideAttrs (_: {
              sphinxBuilders = "html man";
            });
            # 本仓库 nixpkgs 的额外模块包会往 $out/lib/modules/<ver>/ 写空的 dep 占位
            # 文件（与内核自带同名文件内容不同 → buildEnv 冲突；内核在 paths 首位，让内核
            # 优先，depmod 随后重建）。另外 xpad-noone 这类自定义 installPhase 的包不会安装
            # kmodigest 生成的 <module>.ko.cer，聚集器按 modules.dep 追加证书时会因缺文件
            # 失败，这里只追加真实存在的证书。
            aggregateModules = modules:
              (prev.aggregateModules modules).override {
                buildEnv = args:
                  prev.buildEnv (args
                    // {
                      ignoreCollisions = true;
                      postBuild =
                        lib.replaceStrings
                        ["| xargs -d'\\n' cat >> modules.cer"]
                        ["| while IFS= read -r cert; do [ -f \"$cert\" ] && cat \"$cert\"; done >> modules.cer"]
                        (args.postBuild or "");
                    });
              };
            vivaldi = master.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
              vivaldi-ffmpeg-codecs = master.vivaldi-ffmpeg-codecs;
            };
          }
        )
      ];
    };
  }
)
moduleArgs
