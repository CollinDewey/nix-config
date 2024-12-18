{ ... }:
{
  nixpkgs.overlays = [
    (
      final: prev:
        {
          moonraker-timelapse = prev.callPackage ../pkgs/moonraker-timelapse.nix { };
          moonraker = prev.moonraker.overrideAttrs (final.moonraker-timelapse.moonrakerOverrideAttrs);
        }
    )
  ];
}

