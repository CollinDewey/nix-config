{ config, pkgs, ... }: let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    plasma-manager = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/trunk.tar.gz";
in
{
  imports = [ (import "${home-manager}/nixos") ];
  home-manager.users.collin = {
    imports = [ ( import "${plasma-manager}/modules" ) ];
    home.username = "collin";
    home.homeDirectory = "/home/collin";
    home.stateVersion = "22.05";
    programs.git = {
      enable = true;
      signing.signByDefault = true;
      signing.key = "21A02BCB3C3ABEDA";
      userName = "LegitMagic";
      userEmail = "76862862+LegitMagic@users.noreply.github.com";
    };
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
    programs.plasma = {
      enable = true;
      workspace.clickItemTo = "select";
      files = {
        "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
        "kcmfonts"."General"."forceFontDPI" = 96;
        "kwinrc" = {
          "Effect-PresentWindows"."BorderActivateAll" = 9;
          "TabBox"."BorderActivate" = 9;
          "Plugins"."wobblywindowsEnabled" = true;
          "Desktops" = {
            "Number" = 4;
            "Rows" = 2;
          };
          "org.kde.kdecoration2" = {
            "ButtonsOnLeft" = "";
            "ButtonsOnRight" = "SBFIAX";
          };
          "MouseBindings"."CommandAllKey" = "Alt";
        };
        "kdeglobals" = {
          "KDE"."widgetStyle" = "kvantum";
          "Icons"."Theme" = "Papirus-Dark";
        };
      };
    };
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    #sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
    #sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1";
    #sessionVariables.GTK_USE_PORTAL = "1";
    #Needs hardware.opengl.extraPackages = [vaapiVdpau libvdpau-va-gl]
    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      QT_STYLE_OVERRIDE = "kvantum";
      MOZ_DISABLE_CONTENT_SANDBOX = "1";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      GTK_USE_PORTAL = "1";
    };
    
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    #Screw Discord
    home.file.".config/discord/settings.json" = {
      text = builtins.toJSON {
        "SKIP_HOST_UPDATE" = true;
        "UPDATE_ENDPOINT" = "https://updates.goosemod.com/goosemod";
        "NEW_UPDATE_ENDPOINT" = "https://updates.goosemod.com/goosemod/";
      };
    };

    home.packages = with pkgs; [
      firefox
      kate
      discord
      flameshot
      filelight
      solaar
      mpv
      papirus-icon-theme
      krita
      conky
      obs-studio
      steam
      peek
      lxqt.pavucontrol-qt
      lutris
      virt-manager
      guvcview
      gwenview
      kdenlive
      krdc
      ark
      freerdp
      wireshark
      keeweb
      cpu-x
      vscode
      libsForQt5.qtstyleplugin-kvantum
      moonlight-qt
      partition-manager
      gnome.simple-scan
      clementine
      audacity
      scrcpy
      lunar-client
      polymc
      conky
      google-chrome
      grapejuice
      teams
      #cura
      arduino
      onlyoffice-bin
      wpsoffice
      softmaker-office
      obsidian
      freerdp
      ghidra
      godot
      plasma-systemmonitor
      tigervnc
      snes9x-gtk
      heroic
      python3
      gifski
      yt-dlp
      x11vnc
      ffmpeg-full
    ];
  };
}