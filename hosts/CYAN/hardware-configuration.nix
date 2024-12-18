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
    kernelParams = lib.mkDefault [ "amd_pstate=active" "iommu=pt" "kvm.ignore_msrs=1" "report_ignored_msrs=0" ];
    #kernelModules = [ "kvmfr" "i2c-dev" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelPatches = [{
      name = "fix-nvidia-amdgpu-pat-mem";
      patch = null;
      extraConfig = "HSA_AMD_SVM n";
    }]; # https://gitlab.freedesktop.org/drm/amd/-/issues/2794
    extraModulePackages = with config.boot.kernelPackages; [ (kvmfr.overrideAttrs (_: { patches = (pkgs.fetchpatch { url = "https://github.com/gnif/LookingGlass/commit/7305ce36af211220419eeab302ff28793d515df2.patch"; hash = "sha256-97nZsIH+jKCvSIPf1XPf3i8Wbr24almFZzMOhjhLOYk="; stripLen = 1; }); })) v4l2loopback ];
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
    graphics = {
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Video
  services.colord.enable = true;
  specialisation = {
    NoNVIDIA.configuration = {
      system.nixos.tags = [ "NoNVIDIA" ];
      services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];
      boot = {
        blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
        extraModprobeConfig = ''
          blacklist nouveau
          options nouveau modeset=0
        '';
      };
      modules.virtualisation.nvidia = lib.mkForce false;
    };
  };
  services.xserver = {
    videoDrivers = lib.mkDefault [ "amdgpu" "nvidia" ];
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
  hardware.nvidia.open = false;
  environment.variables.__RM_NO_VERSION_CHECK = "1";
  environment.variables.KWIN_DRM_DEVICES = "/dev/dri/card1";

  # Networking
  time.timeZone = "America/Louisville";
  systemd.network = {
    enable = true;
    links = {
      "10-gig-lan" = {
        matchConfig.PermanentMACAddress = "08:bf:b8:13:96:f4";
        linkConfig.Name = "lan0";
      };
      "10-ten-gig-lan" = {
        matchConfig.PermanentMACAddress = "08:bf:b8:13:8f:fd";
        linkConfig.Name = "ten0";
      };
    };
    networks = {
      "10-ten-lan" = {
        matchConfig.Name = "ten0";
        address = [ "172.26.1.10/16" ];
        routes = [{
          Gateway = "172.26.0.1";
          Destination = "172.26.0.0/16";
        }];
      };
    };
  };
  networking = {
    hostName = "CYAN";
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:ten0" ];
    };
    hosts = {
      "172.26.0.100" = [ "TEAL" ]; # 10 Gigabit Link
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
    #"/mnt/TEAL" = {
    #  device = "TEAL:/";
    #  fsType = "nfs";
    #  options = nfs_opts;
    #};
    "/mnt/vm_storage" = {
      device = "TEAL:/vm_storage";
      fsType = "nfs";
      options = nfs_opts;
    };
    #"/mnt/snapshots" = {
    #  device = "TEAL:/snapshots";
    #  fsType = "nfs";
    #  options = nfs_opts;
    #};
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
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
        "/var/lib/libvirt" # Keep KVM junk
        { directory = "/var/lib/syncthing"; user = "collin"; group = "collin"; } # Syncthing
        "/var/lib/NetworkManager" # I like using WiFi
        "/etc/nixos" # Not nuke my configuration
        { directory = "/var/lib/private/ollama"; user = "ollama"; group = "ollama"; } # Ollama
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
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
