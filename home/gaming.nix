{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.gaming;
stable = import inputs.nixpkgs-stable { system = pkgs.system; };
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
      (retroarch.withCores (
        cores: with cores; [
          snes9x
          mupen64plus
        ]
      ))
      prismlauncher
      clonehero
      ryujinx
      stable.lime3ds # Likely to be changed to azahar at some point
      gamescope
      r2modman
    ];
  };
}
