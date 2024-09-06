{ pkgs, ... }:
{
  nixpkgs.overlays = [( self: super: {
    linux-firmware = super.linux-firmware.overrideAttrs (old: {
      version = "20240709";
      src = pkgs.fetchzip {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20240709.tar.gz";
        hash = "sha256-BopPZDVQMmhLo9qTpozIea2amaZNQvwhgEIcpKMPAKs=";
      };
    });
  })];
}