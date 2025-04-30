{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    package = pkgs.brave;
    extensions = [
      { id = "fcfebhekhbkhjjimonjmbgmkbclheaoh"; } # ACG助手 - 提供哔哩哔哩(bilibili)视频下载消息推送
      { id = "jjfgljkjddpcpfapejfkelkbjbehagbh"; } # Aria2 Explorer
      { id = "eibibhailjcnbpjmemmcaakcookdleon"; } # Enhanced GitHub
      { id = "gpphkfbcpidddadnkolkpfckpihlkkil"; } # React Developer Tools
      { id = "jmkaglaafmhbcpleggkmaliipiilhldn"; } # Video DownloadHelper
      { id = "lnfcfeidnipnphibahlkdhalpkpmccoc"; } # pakku：哔哩哔哩弹幕过滤器
      { id = "amkbmndfnliijdhojkpoglbnaaahippg"; } # 沉浸式翻译 - 网页翻译插件 | PDF翻译 | 免费
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

}
