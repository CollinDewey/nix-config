{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gaming;

in {
  options.modules.gaming = { enable = mkEnableOption "gaming"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      #steam # Enable via programs.steam.enable for now in the global config
      #gamemode # Enable via programs.gamemode.enable = true;
      mangohud
      lutris
      godot3
      heroic
      dolphin-emu
      (retroarch.override {
        cores = with libretro; [
          snes9x
        ];
      })
      prismlauncher-qt5
      clonehero
      yuzu-ea
      ryujinx
      gamescope
    ];
  };
}
