{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.virtualisation;

in {
  options.modules.virtualisation = {
    docker = mkEnableOption "docker";
    libvirt = mkEnableOption "libvirt";
    nvidia = mkEnableOption "nvidia";
  };
  config = {
    virtualisation.docker.enable = cfg.docker;
    environment.systemPackages = mkIf cfg.docker [ pkgs.ctop ];
    virtualisation.docker.enableNvidia = cfg.docker && cfg.nvidia;

    security.polkit.enable = lib.mkDefault cfg.libvirt; # Needed for libvirtd
    virtualisation.libvirtd.enable = cfg.libvirt;
  };
}
