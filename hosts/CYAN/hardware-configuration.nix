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
    extraModulePackages = with config.boot.kernelPackages; [ (kvmfr.overrideAttrs (_: { patches = []; })) v4l2loopback ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
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
    opengl.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.rocm-runtime
      amdvlk
    ];
    opengl.extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Video
  services.colord.enable = true;
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
  environment.variables.__RM_NO_VERSION_CHECK = "1";

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "CYAN";
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:eno2" ];
    };
    interfaces.eno2 = {
      ipv4 = {
        addresses = [{
          address = "10.133.133.3";
          prefixLength = 24;
        }];
        routes = [{ # Access container LAN through 10GbE link
          address = "10.111.111.0";
          prefixLength = 24;
          via = "10.133.133.1";
        }];
      };
      useDHCP = false;
    };
    hosts = {
      "10.133.133.2" = [ "TEAL" ]; # 10 Gigabit Link
    };
    firewall = {
      enable = false;
      checkReversePath = false; # Wireguard
    };
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # Power (Not working)
  #power.ups = { # Based on https://github.com/Baughn/machine-config/blob/7934ea28473c6636112aacb38f138d2546687d23/tsugumi/configuration.nix#L232
  #  enable = true;
  #  maxStartDelay = 0;
  #  ups.ups = {
  #    port = "auto";
  #    driver = "usbhid-ups";
  #  };
  #};
  #systemd.services.upsd.preStart = "mkdir -p /var/lib/nut -m 0700";
  #systemd.services.upsdrv.serviceConfig.User = "root";
  #environment.etc."nut/upsd.conf".text = "";
  #/etc/nut/upsd.users and /etc/nut/upsmon.conf in persist for now. Move to secrets eventually.

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
      extraOptions = [ "--thread-count" "4" "--loadavg-target" "5.0" ];
    };
  };

  # Partitioning
  disko.devices = import ./disko.nix;

  # NFS
  fileSystems = {
    "/mnt/TEAL" = {
      device = "TEAL:/";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/virtualization" = {
      device = "TEAL:/var/lib/libvirt";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/virtualization_hdd" = {
      device = "TEAL:/var/lib/libvirt/images_hdd";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/snapshots" = {
      device = "TEAL:/snapshots";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/services" = {
      device = "TEAL:/services";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/cyber" = {
      device = "TEAL:/cyber";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/storage" = {
      device = "TEAL:/storage";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/global" = {
      device = "TEAL:/network_share/Global";
      fsType = "nfs";
      options = nfs_opts;
    };
    "/mnt/cmd" = {
      device = "TEAL:/network_share/CMD";
      fsType = "nfs";
      options = nfs_opts;
    };
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
      #"/etc/nut/upsd.users"
      #"/etc/nut/upsmon.conf"
    ];
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
