{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
    pkgs.steamPackages.steam
  ];

  # Cross compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NFS
  services.nfs.server.enable = true;

  # Goofy different distro name just for /pts/
  system.nixos.distroName = "NyxOS";

  # State
  system.stateVersion = "23.11";
}
