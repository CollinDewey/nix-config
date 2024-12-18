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
  ];
}

