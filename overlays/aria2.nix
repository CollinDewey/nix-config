{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (
      self: super:
        {
          aria2 = super.aria2.overrideAttrs (old: { 
            patches = (old.patches or []) ++ [
                ./aria2-remove-the-limit-of-max-connection-per-server.patch 
            ]; 
          });
        }
    )
  ];
}
