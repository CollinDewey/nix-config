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
      kdePackages.filelight
      lm_sensors
      pciutils
      xdotool
      kdePackages.krdc
      bitwarden-desktop
      bitwarden-cli
      bitwarden-menu
      simple-scan
      obsidian
      vscode
      nil
      tigervnc
      x11vnc
      input-leap
      imhex
      kdePackages.partitionmanager
    ];
  };
}
