{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.config;

in {
  options.modules.config = { enable = mkEnableOption "config"; };
  config = mkIf cfg.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    nixpkgs.config.allowUnfree = true;
 };
}
