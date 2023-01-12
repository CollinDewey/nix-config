{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
    pkgs.teensy-udev-rules
    pkgs.steamPackages.steam
    pkgs.android-udev-rules
  ];

  # SDDM workaround for starting before drivers load
  systemd.services.display-manager.preStart = ''${pkgs.coreutils}/bin/sleep 1'';

  # State
  system.stateVersion = "23.05";
}