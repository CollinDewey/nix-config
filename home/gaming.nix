{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gaming;

in {
  options.modules.gaming = { enable = mkEnableOption "gaming"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
      lutris
      #moonlight-qt (broken for some reason?)
      lunar-client
      #grapejuice #New ROBLOX update breaks stuff
      godot
      heroic
      prismlauncher-qt5
    ];
  };
}
