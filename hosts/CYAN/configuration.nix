{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
  ];

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };
  programs.gamemode.enable = true;
  chaotic.steam.extraCompatPackages = with pkgs; [ proton-ge-custom ];
  programs.dconf.enable = true; # Virt-manager keep config

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "collin";
  };

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
