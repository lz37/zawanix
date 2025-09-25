{...}: {
  programs.plasma.configFile.plasmanotifyrc = {
    "Applications/koi"."Seen" = true;
    "Applications/org.telegram.desktop"."Seen" = true;
    "Applications/qq"."Seen" = true;
    "Applications/teams-for-linux"."Seen" = true;
    Notifications.PopupPosition = "TopCenter";
  };
}
