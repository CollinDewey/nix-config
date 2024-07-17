{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.plasma;

in {
  options.modules.plasma = {
    enable = mkEnableOption "plasma";
  };
  config = mkIf cfg.enable {
    # X Server
    services = {
      xserver = {
        enable = true;
        xkb.layout = "us";
        windowManager.openbox.enable = true;
      };
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        theme = "catppuccin-mocha";
        wayland = {
          enable = true;
          compositor = "kwin";
        };
      };
    };
    hardware.opengl.enable = true;
    hardware.opengl.driSupport32Bit = true;

    # Extra Global Font Packages (https://nixos.wiki/wiki/Fonts)
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];

    # Extra Packages
    environment.systemPackages = [(
      pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font  = "Hack";
        fontSize = "10";
        #background = "${./wallpaper.png}";
        #loginBackground = true;
      }
    )];

    programs.kdeconnect.enable = true;

    # Audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    services.udev.extraRules = ''
      # 96Hz
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4003", MODE="0666"
      # 88.2Hz
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4004", MODE="0666"
      # 48Hz
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4005", MODE="0666"
      # 44.1Hz
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4006", MODE="0666"
      # 44.1Hz/48/88.2/96Khz
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4007", MODE="0666"
      # 48Hz with Mic
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4125", MODE="0666"
      # 44.1Hz with Mic
      KERNEL=="hidraw*", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="4126", MODE="0666"
      # Polyglot Javelin
      KERNEL=="hidraw*", ATTRS{idVendor}=="9000", ATTRS{idProduct}=="400d", MODE="0666"
    '';
  };
}
