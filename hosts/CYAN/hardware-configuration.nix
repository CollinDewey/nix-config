{ config, lib, pkgs, inputs, ... }:

{
  # Imports
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ];

  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelParams = lib.mkDefault [ "mitigations=off" "retbleed=off" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Filesystems
    supportedFilesystems = [ "ntfs" ];

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Video
  services.xserver = {
    videoDrivers = [ "amdgpu" "nvidia" ];
  };

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "CYAN";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      checkReversePath = false; # Wireguard
    };
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # VFIO NVIDIA 2080
  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "vfio" ];
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "vfio_virqfd"

        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      kernelParams = [ "mitigations=off" "retbleed=off" "amd_iommu=on" "vfio-pci.ids=10de:1e82,10de:10f8,10de:1ad8" "default_hugepagesz=1G" "hugepagesz=1G" "hugepages=32" "amd_pstate=active" ];
    };
    virtualisation.spiceUSBRedirection.enable = true;
  };

  # Disks
  boot.tmp.cleanOnBoot = true;

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
      hashTableSizeMB = 2048;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "4" "--loadavg-target" "3.0" ];
    };
  };

  # Partitioning
  disko.devices = import ./disko.nix;

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log" # Keep system logs
      "/var/lib/docker" # Keep Docker junk
      "/var/lib/libvirt" # Keep KVM junk
      "/var/lib/NetworkManager" # I like using WiFi
      "/etc/nixos" # Not nuke my configuration
    ];
    files = [
      "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
      "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
      "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
      "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
      "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
    ];
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
