{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.printing;

in {
  options.modules.printing = { enable = mkEnableOption "printing"; };
  config = mkIf cfg.enable {

    # Enable CUPS to print documents
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplipWithPlugin ];
    services.printing.cups-pdf.enable = true;

    # Enable SANE to scan documents
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [ pkgs.hplipWithPlugin pkgs.epkowa ];
    services.saned.enable = true;

    # Enable avahi to automagically find printers
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;

  };
}
