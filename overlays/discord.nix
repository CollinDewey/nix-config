{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (
      self: super:
        {
          discord = super.discord.override {
            withOpenASAR = true;
            withVencord = true;
            nss = pkgs.nss_latest;
          };

          discord-ptb = super.discord-ptb.override {
            withOpenASAR = true;
            withVencord = true;
            nss = pkgs.nss_latest;
          };
        }
    )
  ];
}
