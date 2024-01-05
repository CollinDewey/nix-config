{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
    pkgs.android-udev-rules
  ];

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

  # Goofy different distro name just for /pts/
  system.nixos.distroName = "NyxOS";

  # State
  system.stateVersion = "23.11";
}
