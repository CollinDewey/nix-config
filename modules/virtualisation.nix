{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.virtualisation;

in {
  options.modules.virtualisation = { 
    enable = mkEnableOption "virtualisation"; 
    nvidia = mkEnableOption "nvidia";  
  };
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    security.polkit.enable = true; # Needed for libvirtd
    virtualisation.libvirtd.enable = true;
    virtualisation.docker.enableNvidia = cfg.nvidia;
  };
}