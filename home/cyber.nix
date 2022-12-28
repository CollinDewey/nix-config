{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.cyber;

in {
  options.modules.cyber = { enable = mkEnableOption "cyber"; };
  config = mkIf cfg.enable {
   home.packages = with pkgs; [
    wireshark
    ghidra
    imhex
   ];
 };
}