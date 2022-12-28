{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.gaming;

in {
  options.modules.gaming = { enable = mkEnableOption "gaming"; };
  config = mkIf cfg.enable {
   home.packages = with pkgs; [
    steam
    lutris
    moonlight-qt
    lunar-client
    grapejuice
    godot
    heroic
    prismlauncher-qt5
   ];
 };
}