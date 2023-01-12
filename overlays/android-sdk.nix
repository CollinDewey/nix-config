{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    inputs.android-nixpkgs.overlays.default
  ];
}