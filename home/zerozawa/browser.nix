{ pkgs, config, ... }:
{
  programs = {
    chromium = {
      enable = true;
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];
      package = pkgs.brave;
      extensions = [
        { id = "kpbnombpnpcffllnianjibmpadjolanh"; } # ACG助手 - 提供哔哩哔哩(bilibili)视频下载消息推送
        { id = "mpkodccbngfoacfalldjimigbofkhgjn"; } # Aria2 Explorer
        { id = "anlikcnbgdeidpacdbdljnabclhahhmd"; } # Enhanced GitHub
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; } # React Developer Tools
        { id = "lmjnegcaeklhafolokijcfjliaokphfk"; } # Video DownloadHelper
        { id = "jklfcpboamajpiikgkbjcnnnnooefbhh"; } # pakku：哔哩哔哩弹幕过滤器
        { id = "bpoadfkcbjbfhfodiogcnhhhpibjhbnh"; } # 沉浸式翻译 - 网页翻译插件 | PDF翻译 | 免费
        { id = "fdpohaocaechififmbbbbbknoalclacl"; } # GoFullPage - Full Page Screen Capture
        { id = "afoibpobokebhgfnknfndkgemglggomo"; } # HTML5 Outliner
        { id = "eningockdidmgiojffjmkdblpjocbhgh"; } # Header Editor
        { id = "bcjindcccaagfpapjjmafapmmgkkhgoa"; } # JSON Formatter
        { id = "blipmdconlkpinefehnmjammfjpmpbjk"; } # Lighthouse
        { id = "nhdogjmejiglipccpnnnanhbledajbpd"; } # Vue.js devtools
        { id = "bgejgfcdaicmfbfphchgcdgnpnbcondb"; } # 扩展管理器
        { id = "gcalenpjmijncebpfijmoaglllgpjagf"; } # 篡改猴测试版
      ];
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
