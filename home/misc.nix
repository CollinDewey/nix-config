{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.misc;

in {
  options.modules.misc = { enable = mkEnableOption "misc"; };
  config = mkIf cfg.enable {
   home.packages = with pkgs; [
    virt-manager
    solaar
   ];
 };
}