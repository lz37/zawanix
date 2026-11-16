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
      permittedInsecurePackages = [
        "lightnovel-crawler-4.14.0"
      ];
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
            # 启用 NUR。zerozawa 仓库必须用它自己的 nixpkgs rev 实例化，才能对上
            # NUR CI 推到 zerozawa.cachix.org 的产物（用 prev 会换 stdenv → 全部 miss）。
            # 但 `legacyPackages` 的 config 写死在 NUR flake 里（只有 allowUnfree），
            # 消费侧 nixpkgs.config 到不了它，带 knownVulnerabilities 的包直接 refuse。
            # 这里用同一个 rev 重建实例、config 与 CI 一致，只补上放行项；
            # config 不参与 drv 哈希，缓存口径不变。
            nur = import inputs.nur {
              nurpkgs = prev;
              pkgs = prev;
              repoOverrides = {
                zerozawa = import inputs.zerozawa-nur {
                  pkgs = import inputs.zerozawa-nur.inputs.nixpkgs {
                    inherit system;
                    config = {
                      allowUnfree = true;
                      inherit (nixpkgsConfig) permittedInsecurePackages;
                    };
                  };
                };
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
            # nixpkgs-master 把 vscode 版本写成两段式（"1.146"，下载时才 pad 到 1.146.0），
            # 但 nix-vscode-extensions 的 forVSCodeVersion 用严格 SemVer 正则解析，两段式直接
            # throw "Invalid SemVer"。这里统一 pad 成三段再交给选版逻辑。
            vscode-selected-extensionsCompatible =
              let
                vscodeVersion = lib.versions.pad 3 (lib.getVersion vscode-selected);
              in
              ((pkgs.usingFixesFrom pkgs).forVSCodeVersion vscodeVersion)
              // {
                forVscode = pkgs.nix4vscode.forVscodeVersion vscodeVersion;
                forVscodePrerelease = pkgs.nix4vscode.forVscodeVersionPrerelease vscodeVersion;
                forOpenVsx = pkgs.nix4vscode.forOpenVsxVersion vscodeVersion;
                forOpenVsxPrerelease = pkgs.nix4vscode.forOpenVsxVersionPrerelease vscodeVersion;
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
            # Go 1.26 的 cgo 标志白名单拒绝 GNU ld 的 `-l:<file>` 语法，而 nixpkgs 的
            # rdpclient.patch 仍打上 `#cgo linux LDFLAGS: -l:librdp_client.a`，导致
            # teleport（withRdpClient，默认开）在 tool/teleport 包上直接报
            # "invalid flag in #cgo LDFLAGS"。`-lrdp_client` 靠补丁里同一个
            # -L${SRCDIR}/../../../../../lib 就能找到预置的 librdp_client.a。
            teleport = prev.teleport.overrideAttrs (oa: {
              postPatch = (oa.postPatch or "") + ''
                sed -i 's/-l:librdp_client\.a/-lrdp_client/' \
                  lib/srv/desktop/rdp/rdpclient/client.go
              '';
              # Go 1.26 还会拒绝 cgo LDFLAGS 里含 LLVM bitcode 的静态库
              # （"disallowed LTO section"），Rust 编出的 librdp_client.a 每个目标文件
              # 都带 .llvmbc/.llvmcmd。nixpkgs 的 preBuild 只是软链进 lib/，这里换成
              # 实体副本再去掉这两节；符号表不动，链接结果等价。
              preBuild = (oa.preBuild or "") + ''
                cp --remove-destination "$(readlink -f lib/librdp_client.a)" lib/librdp_client.a
                chmod u+w lib/librdp_client.a
                objcopy --remove-section=.llvmbc --remove-section=.llvmcmd lib/librdp_client.a
              '';
              nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ prev.binutils ];
            });
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
