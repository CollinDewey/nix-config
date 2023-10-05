{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.communication;

in {
  options.modules.communication = { enable = mkEnableOption "communication"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      discord-ptb
      teams-for-linux
    ];
  };
}
