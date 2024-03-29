{ modulesPath, pkgs, lib, ... }:
{
  # Boot
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    # Kernel
    initrd.kernelModules = [ "nvme" ];
    kernelParams = [ "mitigations=off" "retbleed=off" "panic=1" "boot.panic_on_fail" ];
    kernelPackages = pkgs.linuxPackages_latest;

    # Boot
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };
  systemd.enableEmergencyMode = false;

  # Hardware
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  services.fstrim.enable = true;

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "BROWN";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;
    firewall.enable = true;
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # State
  system.stateVersion = "21.11";

  # Disks
  boot.tmp.cleanOnBoot = true;
  swapDevices = [{ device = "/swapfile"; size = 4096; }];
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };
    "/mnt/Block" = {
      device = "/dev/disk/by-label/Block";
      fsType = "ext4";
    };
  };

  # Persistance
  users.mutableUsers = false;

  # Sops Key File Location
  sops.age.keyFile = "/root/sops-key.txt";
}
