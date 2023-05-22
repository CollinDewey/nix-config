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
    nameservers = [ "208.67.222.222" "208.67.220.220" ];
    defaultGateway = "172.16.0.1";
    useDHCP = false;
    firewall.enable = false;
    vlans = {
      iot = {
        id = 10;
        interface = "eth0";
      };
    };
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = "172.16.0.3";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
      iot = {
        ipv4.addresses = [{
          address = "172.16.1.3";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
    };
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
    "/mnt/Seagate3TB" = {
      device = "/dev/disk/by-uuid/172ff5cd-d4cd-48fb-ac31-3a6d0e9902e6";
      fsType = "ext4";
      options = [ "auto,nofail,noatime,errors=remount-ro,x-systemd.mount-timeout=5" ];
    };
    "/var/www" = {
      device = "overlay";
      fsType = "overlay";
      options = [ "defaults,x-systemd.requires=/mnt/Seagate3TB,lowerdir=/mnt/Seagate3TB/www,upperdir=/home/collin/Docker/php/contents,workdir=/home/collin/Docker/php/workdir" ];
    };
  };

  # Persistance
  users.mutableUsers = false;

  # Sops Key File Location
  sops.age.keyFile = "/root/sops-key.txt";
}
