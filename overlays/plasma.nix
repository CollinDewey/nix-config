{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      libsForQt5 = prev.libsForQt5.overrideScope' (final': prev': let
        kdeGear = prev'.kdeGear.overrideScope' (final'': prev'': {
          spectacle = final.emptyDirectory;
        });
      in
        {inherit kdeGear;} // kdeGear);
    })
  ];
}
