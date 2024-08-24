{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
    pkgs.android-udev-rules
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
  '';

  # SDDM being weird again. Why? Who knows
  systemd.services.display-manager.preStart = ''${pkgs.coreutils}/bin/sleep 0.5'';

  # Gaming
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
      };
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
  chaotic.steam.extraCompatPackages = with pkgs; [ proton-ge-custom ];
  programs.corectrl.enable = true;
  
  programs.dconf.enable = true; # Virt-manager keep config
  # Syncthing
  services.syncthing = {
    enable = true;
    user = "collin";
  };

  # iPhone
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
  ];

  # Avahi
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # Cross compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NFS
  services.nfs.server.enable = true;

  # Various Services
  services.preload.enable = true;
  services.openvscode-server = {
    enable = true;
    host = "0.0.0.0";
    user = "collin";
    withoutConnectionToken = true;
  };

  # Ollama
  users.users.ollama.uid = 734;
  services.ollama = {
    enable = true;
    user = "ollama";
    host = "0.0.0.0";
    acceleration = "rocm";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      OLLAMA_SCHED_SPREAD = "1";
    };
  };
  nixpkgs.config.rocmSupport = true;

  # State
  system.stateVersion = "23.11";
}
