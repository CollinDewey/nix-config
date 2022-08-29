{ config, pkgs, lib, fetchpatch, ... }: let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    plasma-manager = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/trunk.tar.gz";
    nix-alien-pkgs = import (builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/archive/master.tar.gz") {};
in
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "mitigations=off" "retbleed=off" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  powerManagement.cpuFreqGovernor = "performance";

  fileSystems."/" = {
    device = "/dev/disk/by-label/Linux";
    fsType = "ext4";
  };

  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  boot.cleanTmpDir = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "BURGUNDY";
  services.fstrim.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Louisville";
  time.hardwareClockInLocalTime = true; # Windows is silly and I need it for school
  services.timesyncd.enable = lib.mkForce true;

  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";


  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "colemak/colemak";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    #xkbVariant = "colemak";
    displayManager.sddm.enable = true;
    #displayManager.startx.enable = true;
    desktopManager.plasma5.enable = true;
    screenSection = ''Option         "metamodes" "DP-0.1: nvidia-auto-select +1920+1026 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.2: 1920x1080_60_0 +2288+0 {viewportout=1824x1026+48+27, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.3: 1920x1080 +0+1026 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"'';
  };

  # Enable the Plasma 5 Desktop Environment.
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  specialisation = {
    integrated.configuration = {
      system.nixos.tags = [ "Integrated" ];
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce true;
      powerManagement.enable = true;
      services.power-profiles-daemon.enable = lib.mkForce false;
      services.tlp = {
        enable = true;
        settings = {  
          CPU_SCALING_GOVERNOR_ON_AC="performance";
          CPU_SCALING_GOVERNOR_ON_BAT="powersave";
        };
      };
    };
  };
  hardware.nvidia.prime = {
    #offload.enable = true;
    sync.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    amdgpuBusId = "PCI:6:0:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin pkgs.epkowa ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # GPG
  programs.gnupg.agent.enable = true; 

  imports = [ (import "${home-manager}/nixos") ./ld.nix ]; #<nixpkgs/nixos/modules/virtualisation/qemu-vm.nix> ];
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    initialPassword = "nixos";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmt5hHa/KGH8HAD3fGJwKeP9z+HiObmVxz8SZ2ljhaA4b6NLnMEEda5HuV8UukacWDkRrVT8S5adHlNc2U0lLdmzmo119x5sWt+THDU8QsL2oH6IRjBJVYKBqkClk7ZBfqjzlcC5U58ibEfLIbmiZLZPjzO3ey9khpbzjHL0c882dt0CMPJHWHTtRv935GuD7yBQlRNLZ5EW/IOsw6/l5xlbGPXqCtRjOQ8sj+oivIo/TWBRFK4Qn6glupKei4WAH7ORUJxYt1rzfP0KUBfQsu8mJAIVCSETPpT3OqCtFvl9eCDuSyXRKoBANjS5E71fv3vT/hWrIrcwN+HXE01i1OlQlg7yacajliy87q99fRySfrF8FVISPsg4ft80PpLajVbhXe14IJe9P7IdTV/4rDNF+yZY/KTLRAUkiOLnKiUCgWpiDT9/gAMrFmYcQeGWb8hC7J136bD0wOYtYN6y11qJ4ytccWoNJAwfzmnQzmDceqzb5PY/hKmFN6athOoYc= collin@BURGUNDY" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjE3cJ6iDnaCPsNCvIWl1diZAec6RzZDX6qyaJOV+xkAlzCbeFw0gxHoPzEPkhzbCKWAA3lxTnKC+/oVmwAuLQ4SIeryYwFyq30XIb5+npsO98jZzXt5QonJoB3oPKr7uLqIa6+XDFrV/FW33l6ZcpeMBBTJvsWI8z3Mu89xgpHKOpNl+afNAgVE8QxpDYkHY91ao+3t55yC8c1CbP55FtPJ8s3UEVYw2ZnY7cDAZdm1v3QuDbAF3WJp6uZys1dVNlBquSMmchdCZAXIGiNtbukKV9bzrvXwipuG+fnU3bJjcC08eHgGz/vNKw5H6MQoFfrcA7d0l4b00ecfCfrYSDcPLStZPihHd0iAilixFmlqK6n9+15YlsKv4WtZnGOb42oHI9X+u4JlM4EjbXH0R1gdddf5owiucq3EMuwhbXwfq0YiO1stP6aeX5Yvz+ooH8YOVlK8xdGr1w7jjOxLtMEcaYuOl9YvgP85suPM++J1d97cvbhJ7Hn2OAHeI9mMcJLlYxXwNhWIalp6cTn8Wcrz5uR/d8q44OpN4kaLDG1n/51pxBS0HebRS3hXf/Pc2WAmLwyyXhnNCanDZHNVR6/+8y/SRuZHKSv+bx4RaMPalaWCZjDsX44McfCeLgiu8eXNn64uvdqwJdC+972acc4vFB1Z8d7VNzrIGxKhdbNw== collin@TEAL" ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" ];
  };

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
      #zoom-us
      ghidra
      burpsuite
      godot
      aseprite
      plasma-systemmonitor
      tigervnc
      snes9x-gtk
      heroic
      python3
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    aria
    git
    htop
    iotop
    p7zip
    nettools
    neofetch
    arp-scan
    killall
    sshfs
    unrar
    gifski
    yt-dlp
    x11vnc
    ffmpeg-full
    vaapiVdpau
    libvdpau-va-gl
    rclone
    comma
    youtube-dl
    pinentry-curses
    tmux
    xdotool
    lm_sensors
    pciutils
    nix-alien-pkgs.nix-alien
    nix-alien-pkgs.nix-index-update
    nix-index
    #appimage-run
  ];

  nixpkgs.overlays = [ (
    self: super:
    {
      #discord = super.discord.overrideAttrs (old: {
      #  src = super.fetchurl {
      #    url = "https://dl.discordapp.net/apps/linux/0.0.18/discord-0.0.18.tar.gz";
      #    sha256 = "1hl01rf3l6kblx5v7rwnwms30iz8zw6dwlkjsx2f1iipljgkh5q4";
      #  };
      #});
      discord = super.discord.override {
        withOpenASAR = true;
        nss = pkgs.nss_latest;
      };
      wireplumber = super.wireplumber.overrideAttrs (old: rec {
        version = "0.4.10";
        src = super.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "pipewire";
          repo = "wireplumber";
          rev = version;
          sha256 = "sha256-Z5Uqjw05SdEU9bGLuhdS+hDv7Fgqx4oW92k4AG1p3Ug=";
        };
      });
    } 
  ) ];

  # Make Stuff Pretty With Oh-My-ZSH
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
      theme = "agnoster";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  #services.openssh.permitRootLogin = "yes";

  # Disable the Firewall
  networking.firewall.enable = false;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Enable Docker/Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enableNvidia = true;
  programs.dconf.enable = true;

  # Nix Garbage Collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.settings.auto-optimise-store = true;

  # Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
  '';

  # Nix Auto Update
  system.autoUpgrade.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  #virtualisation.memorySize = 16384;
  #virtualisation.cores = 8;
}
