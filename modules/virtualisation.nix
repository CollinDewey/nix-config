{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.virtualisation;

in {
  options.modules.virtualisation = {
    docker = mkEnableOption "docker";
    podman = mkEnableOption "podman";
    libvirt = mkEnableOption "libvirt";
    nvidia = mkEnableOption "nvidia";
  };
  config = {
    environment.systemPackages = mkIf cfg.docker [ pkgs.ctop ];
    virtualisation.docker = {
      enable = cfg.docker;
      storageDriver = "overlay2"; # BTRFS subvolumes caused issues
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };
    virtualisation.podman = {
      enable = cfg.podman;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    hardware.opengl.driSupport32Bit = lib.mkOverride 999 cfg.nvidia;
    hardware.nvidia-container-toolkit.enable = cfg.nvidia;

    security.polkit.enable = lib.mkDefault cfg.libvirt; # Needed for libvirtd
    virtualisation.libvirtd = {
      enable = cfg.libvirt;
      qemu.swtpm.enable = true;
      parallelShutdown = 10;
    };
  };
}
