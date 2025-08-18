{
  pkgs,
  config,
  lib,
  ...
}:

let
  chromium-extensions =
    {
      browsermcp = "bjfgambnhccakkhmkepdoekmckoijdlc"; # Browser MCP - Automate your browser using VS Code, Cursor, Claude, and more
      acghelper = "kpbnombpnpcffllnianjibmpadjolanh"; # ACG助手 - 提供哔哩哔哩(bilibili)视频下载消息推送
      aria2explorer = "mpkodccbngfoacfalldjimigbofkhgjn"; # Aria2 Explorer
      enhancedgithub = "anlikcnbgdeidpacdbdljnabclhahhmd"; # Enhanced GitHub
      reactdevtools = "fmkadmapgofadopljbjfkapdkoienihi"; # React Developer Tools
      videodownloadhelper = "lmjnegcaeklhafolokijcfjliaokphfk"; # Video DownloadHelper
      pakku = "jklfcpboamajpiikgkbjcnnnnooefbhh"; # pakku：哔哩哔哩弹幕过滤器
      fluentRead = "djnlaiohfaaifbibleebjggkghlmcpcj"; # Open Immersive Translate 开源的沉浸式翻译。
      goFullPage = "fdpohaocaechififmbbbbbknoalclacl"; # GoFullPage - Full Page Screen Capture
      html5Outliner = "afoibpobokebhgfnknfndkgemglggomo"; # HTML5 Outliner
      headerEditor = "eningockdidmgiojffjmkdblpjocbhgh"; # Header Editor
      jsonFormatter = "bcjindcccaagfpapjjmafapmmgkkhgoa"; # JSON Formatter
      lighthouse = "blipmdconlkpinefehnmjammfjpmpbjk"; # Lighthouse
      vuejsdevtools = "nhdogjmejiglipccpnnnanhbledajbpd"; # Vue.js devtools
      extensionManager = "bgejgfcdaicmfbfphchgcdgnpnbcondb"; # 扩展管理器
      tampermonkey = "gcalenpjmijncebpfijmoaglllgpjagf"; # 篡改猴测试版
      ublockOriginLite = "ddkjiahejlhfcafbddmgiahcphecmpfh"; # uBlock Origin Lite (cr你m什么时候s啊)
    }
    |> lib.mapAttrsToList (
      name: id: {
        "${name}" = {
          inherit id;
        };
      }
    )
    |> lib.zipAttrsWith (name: values: (builtins.elemAt values 0));
  chromium-base = {
    commandLineArgs = [ "--password-store=kwallet6" ];
    enable = true;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
    extensions =
      with chromium-extensions;
      # only developer tools
      [
        browsermcp
        jsonFormatter
        vuejsdevtools
        reactdevtools
        html5Outliner
        lighthouse
      ];
  };
  chromium-common = chromium-base // {
    extensions = builtins.attrValues chromium-extensions;
  };
in
{
  home = {
    sessionVariables = {
      CHROME_PATH = "${pkgs.chromium}/bin/chromium";
    };
  };
  programs = {
    chromium = chromium-base;
    google-chrome = {
      enable = true;
      package = pkgs.google-chrome.overrideAttrs (oldAttrs: {
        postInstall = ''
          dist=stable
          ln -s $out/bin/google-chrome-$dist $out/bin/chrome
        '';
      });
    };
    brave = chromium-common;
    vivaldi = chromium-common // {
      commandLineArgs = (import ./common.nix).commandLineArgs ++ chromium-common.commandLineArgs;
    };
    firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "zh-CN"
      ];
      policies = {
        DefaultDownloadDirectory = "${config.zerozawa.path.downloads}";
      };
      profiles.default = {
        isDefault = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          pakkujs
          enhanced-github
          aria2-integration
          react-devtools
          vue-js-devtools
          violentmonkey
          header-editor
          immersive-translate
        ];
      };
    };
  };
}
