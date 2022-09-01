{ config, pkgs, fetchpatch, ... }:
{
  nixpkgs.overlays = [ (
    self: super:
    {
      discord = super.discord.override {
        withOpenASAR = true;
        nss = pkgs.nss_latest;
      };
      wireplumber = super.wireplumber.overrideAttrs (old: rec {
        version = "0.4.10";
        src = super.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "pipewire";
          repo = "wireplumber";
          rev = version;
          sha256 = "sha256-Z5Uqjw05SdEU9bGLuhdS+hDv7Fgqx4oW92k4AG1p3Ug=";
        };
      });
    } 
  ) ];
}