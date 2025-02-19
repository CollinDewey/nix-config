{ ... }:
{
  nixpkgs.overlays = [
    # Borrowed from Zumorica/GradientOS
    (
      final: prev:
        {
          klipper = prev.klipper.overrideAttrs (finalAttrs: prevAttrs: {
            buildInputs = [
              prev.openblasCompat
              (prev.python3.withPackages (p: with p; [ can cffi pyserial greenlet jinja2 markupsafe numpy matplotlib ]))
            ];
          });
        }
    )
    # NixOS/nixpkgs#279552
    (
      final: prev: 
        {
          klipper-firmware = prev.klipper-firmware.overrideAttrs (old: {
            installPhase = ''
              mkdir -p $out
              cp ./.config $out/config
              cp -r out/* $out
            '';
          });
        }
    )
  ];
}

