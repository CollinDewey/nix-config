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

      qemu = prev.qemu.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            cp -f ${final.OVMFFull.fd}/FV/OVMF_CODE.fd $out/share/qemu/edk2-x86_64-code.fd
            cp -f ${final.OVMFFull.fd}/FV/OVMF_CODE.ms.fd $out/share/qemu/edk2-x86_64-secure-code.fd
          '';
      });
    })
  ];
}
