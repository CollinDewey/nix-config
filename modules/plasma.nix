{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.plasma;

in {
  options.modules.plasma = { enable = mkEnableOption "plasma"; };
  config = mkIf cfg.enable {
    # X Server
    services.xserver = {
      enable = true;
      layout = "us";
      #xkbVariant = "colemak";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      windowManager.openbox.enable = true;
    };
    hardware.opengl.enable = true;
    hardware.opengl.driSupport32Bit = true;

    # Extra Global Font Packages (https://nixos.wiki/wiki/Fonts)
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];

    # Audio Server
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
