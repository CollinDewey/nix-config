{ config, ... }:

{
  # Enable CUPS to print documents
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Enable SANE to scan documents
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin pkgs.epkowa ];

  # Enable avahi to automatically find printers
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
}