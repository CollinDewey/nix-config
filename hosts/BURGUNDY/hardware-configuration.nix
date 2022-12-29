{ config, lib, pkgs, ... }:

{
  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "mitigations=off" "retbleed=off" ];
    kernelPackages = pkgs.linuxPackages_latest;

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    nvidia.prime = {
      sync.enable = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Video
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    #screenSection = '''';
  };

  # Networking
  time.timeZone = "America/Louisville";
  time.hardwareClockInLocalTime = true; # Windows is silly and I need it for work/school
  networking = {
    hostName = "BURGUNDY";
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      checkReversePath = false; # Wireguard
    };
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";
  specialisation = {
    integrated.configuration = {
      system.nixos.tags = [ "Integrated" ];
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = true;
      powerManagement.enable = true;
      services.power-profiles-daemon.enable = lib.mkForce false;
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC="performance";
          CPU_SCALING_GOVERNOR_ON_BAT="powersave";
        };
      };
    };
  };

  # State
  system.stateVersion = "23.05";

  # Disks
  boot.cleanTmpDir = true;

  # BTRFS Scrubbing
  services.btrfs.autoScrub = {
    fileSystems = [ "/home" ]; # Crosses subpartition bounds
    enable = true;
    interval = "weekly";
  };

  # BTRFS De-duplicating
  services.beesd.filesystems = {
    system = {
      spec = "/home";
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions  = [ "--loadavg-target" "10.0" ];
    };
  };

  # Partitioning
  disko.devices = import ./disko.nix;

  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs";
  };

  # Persistance
  users.mutableUsers = false;
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log" # Keep system logs
      "/var/lib/docker" # Keep Docker junk
      "/var/lib/libvirt" # Keep KVM junk
      "/var/lib/systemd/coredump" # Keep coredumps
      "/etc/nixos" # Not nuke my configuration
      "/etc/ssh" # Not reset my host keys
      "/etc/NetworkManager/system-connections" # I like using WiFi
    ];
    files = [
      "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
    ];
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
