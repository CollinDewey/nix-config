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
      path = "${config.home.homeDirectory}/Android/Sdk";
      packages = sdk: with sdk; [
        build-tools-33-0-1
        build-tools-30-0-3
        cmdline-tools-latest
        emulator
        platform-tools
        platforms-android-32
        patcher-v4
        system-images-android-30-google-apis-x86
      ];
    };
  };
}
