{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      OVMF = prev.OVMF.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            cp ${./Logo.bmp} ./MdeModulePkg/Logo/Logo.bmp
          '';
      });
    })
  ];
}
