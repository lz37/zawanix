{...}: {
  programs.plasma.configFile.plasma-localerc = {
    Formats.LANG = "zh_CN.UTF-8";
    Translations.LANGUAGE = "zh_CN:zh:en:en_US";
  };
}
