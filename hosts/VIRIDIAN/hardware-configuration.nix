{ pkgs, lib, ... }:
{
  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "xhci_pci" "uas" ];
    kernelParams = [ "mitigations=off" "retbleed=off" "console=tty1" "panic=1" "boot.panic_on_fail" "cma=64M" "8250.nr_uarts=1" ]; # Last two needed for 8GB RPi
    kernelPackages = pkgs.linuxPackages_rpi4;

    # Boot
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
  };
  systemd.enableEmergencyMode = false;

  # Hardware
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  services.fstrim.enable = true;

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "VIRIDIAN";
    useDHCP = true;
    firewall.enable = false;
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # State
  system.stateVersion = "21.05";

  # Disks
  boot.tmp.cleanOnBoot = true;
  swapDevices = [{ device = "/swapfile"; size = 4096; }];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Persistance
  users.mutableUsers = false;

  # Sops Key File Location
  sops.age.keyFile = "/root/sops-key.txt";
}
