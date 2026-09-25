{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      immich = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system}.immich;
    })
  ];
}
