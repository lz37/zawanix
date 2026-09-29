{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing.format = "openpgp";

    settings = {
      user = {
        name = config.zerozawa.git.userName;
        email = config.zerozawa.git.userEmail;
      };
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpuser = config.zerozawa.git.userEmail;
        smtpencryption = "tls";
        smtpserverport = 587;
        smtpPass = config.zerozawa.git.smtpPass;
      };
      push.default = "simple"; # Match modern push behavior
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main"; # Set default new branches to 'main'
      log.decorate = "full"; # Show branch/tag info in git log
      log.date = "iso"; # ISO 8601 date format
      # Conflict resolution style for readable diffs
      merge.conflictStyle = "diff3";
    };
  };
}
