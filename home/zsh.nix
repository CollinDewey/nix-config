{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.zsh;

in {
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      history = {
        extended = true; # Timestamps
        size = 1000000; # History loaded in RAM
        save = 1000000; # History saved to file
      };
    };
  };
}
