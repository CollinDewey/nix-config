{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.android-sdk;

in {
  options.modules.android-sdk = { enable = mkEnableOption "android-sdk"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      android-studio
      android-tools
    ];
    android-sdk = {
      enable = true;
      path = "${config.home.homeDirectory}/.android/sdk";
      packages = sdk: with sdk; [
        build-tools-30-0-0
        cmdline-tools-latest
        emulator
        platforms-android-30
        sources-android-30
      ];
    };
  };
}
