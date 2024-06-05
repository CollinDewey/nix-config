{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [( self: super: {
    ryujinx = super.ryujinx.overrideAttrs (old: {
      version = "1.1.1330";
      src = super.fetchFromGitHub {
        owner = "Ryujinx";
        repo = "Ryujinx";
        rev = "d2e97d4161df6aa405073b314526d0fa6e68774d";
        sha256 = "1vf4xwn1z7bfm7c49r2yydx3dqqzqwp0qgzq12m9yskqsj898d63";
      };
    });
  })];
}