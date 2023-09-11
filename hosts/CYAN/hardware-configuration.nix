{ config, lib, pkgs, inputs, ... }:
let
  nfs_opts = [ "x-systemd.automount" "x-systemd.idle-timeout=3600" "noauto" "noatime" ];
in
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
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
    kernelParams = lib.mkDefault [ "mitigations=off" "retbleed=off" "amd_pstate=active" "iommu=pt" "kvm.ignore_msrs=1" "report_ignored_msrs=0" ];
    kernelModules = [ "kvmfr" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
    extraModprobeConfig = ''options kvmfr static_size_mb=64'';
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
    extraConfig = ''
    Section "Device"
    	Identifier      "Radeon"
		  Driver          "amdgpu"
	    BusId           "PCI:3:0:0"
    EndSection
    Section "ServerFlags"
      Option "AutoAddGPU" "off"
    EndSection
    '';
  };

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "CYAN";
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:eno2" ];
    };
    interfaces.eno2 = {
      ipv4.addresses = [{
        address = "10.133.133.2";
        prefixLength = 24;
      }];
      useDHCP = false;
    };
    hosts = {
      "10.133.133.1" = [ "TEAL" ]; # 10 Gigabit Link
    };
    firewall = {
      enable = false;
      checkReversePath = false; # Wireguard
    };
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # VFIO
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
  '';
  environment.etc."looking-glass-client.ini".text = ''
    [app]
    shmFile=/dev/kvmfr0
  '';
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    namespaces = []
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kvmfr0"
    ]
  '';
  #systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 collin kvm -" ];
  virtualisation.spiceUSBRedirection.enable = true;

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

  # NFS
  fileSystems."/mnt/TEAL" = {
    device = "TEAL:/";
    fsType = "nfs";
    options = nfs_opts;
  };
  fileSystems."/mnt/Storage" = {
    device = "TEAL:/mnt/Storage";
    fsType = "nfs";
    options = nfs_opts;
  };
  fileSystems."/mnt/VMs" = {
    device = "TEAL:/mnt/VMs";
    fsType = "nfs";
    options = nfs_opts;
  };
  fileSystems."/mnt/VIRIDIAN" = {
    device = "VIRIDIAN:/";
    fsType = "nfs";
    options = nfs_opts;
  };

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
      "/var/lib/syncthing" # Syncthing
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
