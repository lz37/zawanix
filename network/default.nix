{
  hostName,
  ...
}:

{
  imports = [
    (
      {
        "zawanix-work" = ./zawanix-work.nix;
        "zawanix-glap" = ./zawanix-glap.nix;
      }
      ."${hostName}"
    )
  ];
}
