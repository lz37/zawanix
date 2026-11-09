moduleArgs@{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
(
  {
    osConfig ? null,
    ...
  }:
  let
    systemConfig = if osConfig != null then osConfig else config;
    hw = systemConfig.zerozawa.hardware;
    system = pkgs.stdenv.hostPlatform.system;
    nixpkgsConfig = {
      allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
      allowUnfree = true;
      cudaSupport = hw.isNvidiaGPU;
      rocmSupport = hw.isAmdGPU;
    };
  in
  {
    nixpkgs = {
      config = nixpkgsConfig;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
        inputs.nix-alien.overlays.default
        inputs.nix4vscode.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.llm-agents.overlays.shared-nixpkgs
        # 让 pkgs.hyprland / xdg-desktop-portal-hyprland 全局来自 hyprland flake，
        # grimblast 等传递依赖也随之同源（closure 里只有一个 hyprland）。
        inputs.hyprland.overlays.default
        # 上游打包 bug（hyprland main @ a1d7a78 + hyprutils 0.14.3）：share-picker 目标只
        # 通过 pkg-config 声明 hyprtoolkit/hyprutils/libdrm，但 hyprutils 的 Region.hpp 需要
        # pixman.h、hyprgraphics 的 CairoSurface.hpp 需要 cairo/cairo.h，该目标因此编译失败。
        # 补 buildInputs，并把 pixman-1 加进同一处 pkg_check_modules。
        (final: prev: {
          xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (oa: {
            buildInputs = (oa.buildInputs or [ ]) ++ [
              final.pixman
              final.cairo
            ];
            postPatch = (oa.postPatch or "") + ''
              substituteInPlace hyprland-share-picker/CMakeLists.txt \
                --replace-fail "  libdrm)" "  libdrm pixman-1)"
            '';
          });
        })
        # 连 hypr* 依赖一起换成 flake 锁的版本：aquamarine / hyprutils / hyprgraphics /
        # hyprlang / hyprcursor / hyprtoolkit / hyprwire / hyprland-protocols /
        # hyprland-guiutils / hyprwayland-scanner。插件与本体 ABI 因此同源。
        inputs.hyprland.overlays.hyprland-packages
        (
          final: prev:
          let
            pkgs = prev;
          in
          rec {
            # 启用 NUR
            nur = import inputs.nur {
              nurpkgs = prev;
              pkgs = prev;
              repoOverrides = {
                zerozawa = inputs.zerozawa-nur.legacyPackages.${system};
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
              config = nixpkgsConfig // {
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
            # pkl-vscode 只发 GitHub release 的 vsix（publisher 是 `Pkl`），
            # marketplace 和 open-vsx 两套数据集里都没有，只能固定版本 + hash 构建。
            vscode-extra = {
              pkl.pkl-vscode = pkgs.vscode-utils.buildVscodeExtension {
                pname = "pkl-vscode";
                version = "0.24.0";
                src = pkgs.fetchurl {
                  url = "https://github.com/apple/pkl-vscode/releases/download/0.24.0/pkl-vscode-0.24.0.vsix";
                  hash = "sha256-jIoGG+zxiH7EHMT1ohQQapg7czdY4vOTg0BVo5g0XgI=";
                };
                vscodeExtPublisher = "Pkl";
                vscodeExtName = "pkl-vscode";
                vscodeExtUniqueId = "Pkl.pkl-vscode";
              };
            };
            intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
            nix_version_search_cli = inputs.nix_version_search_cli.packages.${system}.default;
            quickshell = inputs.quickshell.packages.${system}.quickshell.withModules (
              with pkgs.kdePackages;
              [
                kirigami
                kirigami-addons
                kirigami-gallery
              ]
            );
            # apm 0.34.0 的 METADATA 钉了 websockets<17，但代码只用 websockets.sync.client
            #（17 仍保留该 API），nixpkgs 已提供 17.0.1。
            llm-agents = prev.llm-agents // {
              apm = prev.llm-agents.apm.overrideAttrs (oa: {
                pythonRelaxDeps = (oa.pythonRelaxDeps or [ ]) ++ [ "websockets" ];
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
            aggregateModules =
              modules:
              (prev.aggregateModules modules).override {
                buildEnv =
                  args:
                  prev.buildEnv (
                    args
                    // {
                      ignoreCollisions = true;
                      postBuild =
                        lib.replaceStrings
                          [ "| xargs -d'\\n' cat >> modules.cer" ]
                          [ "| while IFS= read -r cert; do [ -f \"$cert\" ] && cat \"$cert\"; done >> modules.cer" ]
                          (args.postBuild or "");
                    }
                  );
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
