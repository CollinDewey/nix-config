{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.office;

in {
  options.modules.office = { enable = mkEnableOption "office"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wpsoffice
      corefonts
      vistafonts
    ];
  };
}
