{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      OVMFFull = prev.OVMFFull.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            cp ${./Logo.bmp} ./MdeModulePkg/Logo/Logo.bmp
          '';
      });
    })
  ];
}
