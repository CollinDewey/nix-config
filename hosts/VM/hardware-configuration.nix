{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "VM";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      checkReversePath = false; # Wireguard
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

  # Persistance
  users.mutableUsers = false;
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log" # Keep system logs
      "/var/lib/docker" # Keep Docker junk
      "/var/lib/libvirt" # Keep KVM junk
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
