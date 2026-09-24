{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      immich = inputs.nixpkgs-unstable.legacyPackages.${final.system}.immich;
    })
  ];
}
