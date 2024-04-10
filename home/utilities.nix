{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.utilities;

in {
  options.modules.utilities = { enable = mkEnableOption "utilities"; };
  config = mkIf cfg.enable {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.packages = with pkgs; [
      firefox
      google-chrome
      filelight
      lm_sensors
      pciutils
      conky
      xdotool
      krdc
      keeweb
      gnome.simple-scan
      #obsidian
      vscode
      tigervnc
      x11vnc
      barrier
      imhex
      partition-manager
    ];
  };
}
