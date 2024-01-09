{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.unity;
in {
  options.modules.unity = { enable = mkEnableOption "unity"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unityhub
    ];
  };
}
