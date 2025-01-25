{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.klipper;
stable = import inputs.nixpkgs-stable { system = pkgs.system; };
in {
  options.modules.klipper = { enable = mkEnableOption "klipper"; };
  config = mkIf cfg.enable {
    home.packages = with stable; [
      #cura
      orca-slicer
    ];
  };
}
