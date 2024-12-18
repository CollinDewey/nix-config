{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.klipper;

in {
  options.modules.klipper = { enable = mkEnableOption "klipper"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      #cura
      (orca-slicer.overrideAttrs (old: {
        # Until PR 360219 is merged.
        cmakeFlags = lib.remove "-DFLATPAK=1" old.cmakeFlags or [ ];
      }))
    ];
  };
}
