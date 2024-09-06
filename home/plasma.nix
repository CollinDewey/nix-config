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
  wallpaper = builtins.fetchurl {
    url = "https://derpicdn.net/img/view/2012/6/17/4901.png";
    sha256 = "56ecbf09d94b32f944bc372b271dd370f4056a67062d3978b09ba294d06868b4";
  };
in {
  options.modules.plasma = { 
    enable = mkEnableOption "plasma";
    packages = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    # Basic KDE Packages
    home.packages = with pkgs; [
      papirus-icon-theme
      kdePackages.qtstyleplugin-kvantum
    ] ++ lib.optionals (cfg.packages) (with pkgs; [
      kdePackages.kate
      lxqt.pavucontrol-qt
      guvcview
      kdePackages.gwenview
      kdePackages.ark
      kdePackages.kimageformats
      kdePackages.colord-kde
      kdePackages.krfb
      kdePackages.plasma-systemmonitor
    ]);

    # Default Settings
    home.file.".config/Kvantum/Bonny-Kvantum".source = config.lib.file.mkOutOfStoreSymlink "${bonny}/Bonny Kvantum Themes/Bonny-Kvantum";
    home.file.".local/share/color-schemes/BonnyDarkColor.colors".source = "${bonny}/Bonny Dark Colorscheme/BonnyDarkColor.colors";
#    home.file.".local/share/kservices5/ServiceMenus".source = ''
#      [Desktop Entry]
#      Type=Service
#      X-KDE-ServiceTypes=KonqPopupMenu/Plugin
#      Icon=media-mount
#      MimeType=application/vnd.squashfs;application/octet-stream;
#      Actions=mount;unmount;

#      [Desktop Action mount]
#      Name=Mount SquashFS
#      Icon=media-mount
#      Exec=(mnt_file="$(basename "%f")" && mnt_dir="/tmp/${mnt_file}-$(echo -n "%f" | sha256sum | head -c 8)" && mkdir -p "$mnt_dir" && (squashfuse "%f" "$mnt_dir" && xdg-open "$mnt_dir") || kdialog --error "Cannot mount, you can try to mount it manually:\n\nsquashfuse \\""%f"\\" \\""$mnt_dir"\\"")

#      [Desktop Action unmount]
#      Name=Unmount SquashFS
#      Icon=media-eject
#      Exec=(mnt_file="$(basename "%f")" && mnt_dir="/tmp/${mnt_file}-$(echo -n "%f" | sha256sum | head -c 8)" && (fusermount -u "$mnt_dir" && rm -r "$mnt_dir") || kdialog --error "Cannot unmount, you can try to unmount it manually:\n\nfusermount -u \\""$mnt_dir"\\"")
#    '';
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
          wallpaper = "${wallpaper}";
        };
        kscreenlocker.appearance.wallpaper = "${wallpaper}";
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
            shakeCursor.enable = false;
          };
          edgeBarrier = 0;
          cornerBarrier = false;
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
        powerdevil.AC = {
          powerButtonAction = lib.mkDefault "shutDown";
          autoSuspend.action = lib.mkDefault "nothing";
          turnOffDisplay.idleTimeout = lib.mkDefault "never";
        };
        panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 26;
            screen = 0;
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
          {
            location = "top";
            height = 26;
            screen = 1;
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
          {
            location = "top";
            height = 26;
            screen = 2;
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

    # XDG
    xdg.portal = {
      enable = true;
      configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    # Theming and Firefox Fix
    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "kvantum";
      GTK_USE_PORTAL = "1";
      MOZ_ENABLE_WAYLAND = "0";
    };
  };
}

