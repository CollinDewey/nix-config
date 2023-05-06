{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.plover;

in {
  options.modules.plover = { enable = mkEnableOption "plover"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      plover.dev
    ];
  };
}
