{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.plasma;

in {
  options.modules.plasma = { enable = mkEnableOption "plasma"; };
  config = mkIf cfg.enable {
    # Basic KDE Packages
    home.packages = with pkgs; [
      kate
      flameshot
      papirus-icon-theme
      lxqt.pavucontrol-qt
      guvcview
      gwenview
      ark
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.colord-kde
      libsForQt5.krfb
      plasma-systemmonitor
      solaar # I use logitech all over
    ];

    # Fix Default Settings
    programs.plasma = {
      enable = true;
      workspace.clickItemTo = "select";
#      configFile = {
#        "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
#        "kcmfonts"."General"."forceFontDPI" = 96;
#        "kwinrc" = {
#          "Effect-PresentWindows"."BorderActivateAll" = 9;
#          "TabBox"."BorderActivate" = 9;
#          "Plugins"."wobblywindowsEnabled" = true;
#          "Desktops" = {
#            "Number" = 4;
#            "Rows" = 2;
#          };
#          "org.kde.kdecoration2" = {
#            "ButtonsOnLeft" = "";
#            "ButtonsOnRight" = "SBFIAX";
#          };
#          "MouseBindings"."CommandAllKey" = "Alt";
#        };
#        "kdeglobals" = {
#          "KDE"."widgetStyle" = "kvantum";
#          "Icons"."Theme" = "Papirus-Dark";
#        };
#      };
    };

    # Theming and Firefox File Dialog Fix
    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "kvantum";
      GTK_USE_PORTAL = "1";
      MOZ_ENABLE_WAYLAND = "0";
    };
  };
}

