{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.plasma;
  bonny = pkgs.fetchFromGitHub {
    owner = "L4ki";
    repo = "Bonny-Plasma-Themes";
    rev = "678d8898f06ed6592b7f1486a7c849a14d496b59";
    sha256 = "sha256-S9s/RGMVdJKB6vAPDgO5gGZ5/G/drvmHtXWMH5ZKz5M=";
  };
  icon = builtins.fetchurl { # Temporary
    url = "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/ad50c97a5208477cb0185d33b5bea661aef44c08/Papirus/24x24/panel/start-here-kde-plasma-symbolic.svg";
    sha256 = "sha256:1cq3iqgsn59ch1bgk1ncbrlgmhwpnfcnflzxdfra2pj0axwm6snr";
  };
in {
  options.modules.plasma = { enable = mkEnableOption "plasma"; };
  config = mkIf cfg.enable {
    # Basic KDE Packages
    home.packages = with pkgs; [
      kate
      papirus-icon-theme
      lxqt.pavucontrol-qt
      guvcview
      gwenview
      ark
      kdePackages.qtstyleplugin-kvantum
      kdePackages.colord-kde
      kdePackages.krfb
      plasma-systemmonitor
    ];

    # Default Settings
    home.file.".config/Kvantum/Bonny-Kvantum".source = config.lib.file.mkOutOfStoreSymlink "${bonny}/Bonny Kvantum Themes/Bonny-Kvantum";
    home.file.".local/share/color-schemes/BonnyDarkColor.colors".source = "${bonny}/Bonny Dark Colorscheme/BonnyDarkColor.colors";
    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "Bonny-Kvantum";
    };
    programs = {
      plasma = {
        enable = true;
        workspace = {
          cursor.theme = "Breeze_Snow";
          colorScheme = "BonnyDarkColor";
          iconTheme = "Papirus-Dark";
          clickItemTo = "select";
        };
        windows.allowWindowsToRememberPositions = true;
        spectacle.shortcuts.captureRectangularRegion = "Print";
        kwin = {
          titlebarButtons = {
            left = [ ];
            right = ["on-all-desktops" "keep-below-windows" "keep-above-windows" "minimize" "maximize" "close"];
          };
          virtualDesktops = {
            rows = 2;
            number = 4;
          };
          effects = {
            desktopSwitching.animation = "slide";
            wobblyWindows.enable = true;
          };
        };
        hotkeys.commands = {
          "launch-firefox" = {
            name = "Launch Firefox";
            key = "Home Page";
            command = "firefox";
          };
          "launch-dolphin" = {
            name = "Launch Dolphin";
            key = "Launch Mail";
            command = "dolphin";
          };
          "lock" = {
            name = "Activate Screen Locker";
            key = "Meta+L";
            command = "lock";
          };
        };
        configFile = {
          "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
          "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
          "kwinrc" = {
            "Compositing"."MaxFPS" = 165; # Really only needed on CYAN, shouldn't hurt anything else though.
            "Effect-overview"."BorderActivate" = 9;
            "MouseBindings"."CommandAllKey" = "Alt";
          };
          "kdeglobals"."KDE"."widgetStyle" = "kvantum";
        };
         panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 26;
            widgets = [
              {
                name = "org.kde.plasma.kicker";
                config.General = {
                  useCustomButtonImage = "true";
                  #customButtonImage = "start-here-kde-plasma-symbolic";
                  customButtonImage = "${icon}";
                  favoriteSystemActions = [];
                };
              }
              "org.kde.plasma.appmenu"
              "org.kde.plasma.panelspacer"
              {
                name = "org.kde.plasma.icontasks";
                config.General.launchers = [];
              }
              "org.kde.plasma.systemtray"
              {
                digitalClock.date.enable = false;
              }
            ];
          }
        ];
      };
      konsole = {
        enable = true;
        defaultProfile = "default";
        profiles.default = {
          name = "default";
          colorScheme = "Solarized";
        };
      };
    };

    # Theming and Firefox File Dialog Fix
    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "kvantum";
      GTK_USE_PORTAL = "1";
      MOZ_ENABLE_WAYLAND = "0";
    };
  };
}

