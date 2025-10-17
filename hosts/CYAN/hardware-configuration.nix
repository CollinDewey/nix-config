{ config, lib, pkgs, inputs, ... }:
let
  nfs_opts = [ "x-systemd.automount" "x-systemd.idle-timeout=3600" "noauto" "noatime" ];
in
{
  # Imports
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nvidia-vgpu.nixosModules.nvidia-vgpu
  ];

  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
    kernelParams = lib.mkDefault [ "amd_pstate=active" "iommu=pt" "kvm.ignore_msrs=1" "report_ignored_msrs=0" ];
    #kernelModules = [ "kvmfr" "i2c-dev" ];
    #kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelPackages = pkgs.linuxPackages_6_6; # Lol
    kernelPatches = [
      {
        name = "fix-nvidia-amdgpu-pat-mem";
        patch = null;
        extraConfig = "HSA_AMD_SVM n";
      } # https://gitlab.freedesktop.org/drm/amd/-/issues/2794
      {
        name = "amdgpu-ignore-ctx-privileges";
        patch = pkgs.fetchpatch {
          name = "cap_sys_nice_begone.patch";
          url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
          hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
        };
      } # https://github.com/NixOS/nixpkgs/issues/217119
    ];
    extraModulePackages = with config.boot.kernelPackages; [ kvmfr v4l2loopback ];
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
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
      ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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
      hardware.nvidia.vgpu.enable = lib.mkForce false;
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
  hardware.nvidia = {
    open = false;
    modesetting.enable = false;
    vgpu = {
      enable = true;
      copyVGPUProfiles = {
        "1E82:0000" = "1E30:12BA"; # 2080
      };
      vgpu_driver_src.url = "https://teal.terascripting.com/internal/NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.55.zip";
      profile_overrides = {
        "GRID RTX6000-1Q" = {
          frameLimiter = false;
          vramMB = 768;
        };
        "GRID RTX6000-2Q" = {
          frameLimiter = false;
          vramMB = 1536;
        };
        "GRID RTX6000-4Q" = {
          frameLimiter = false;
          vramMB = 3584;
        };
        "GRID RTX6000-6Q" = {
          frameLimiter = false;
          vramMB = 5632;
        };
        "GRID RTX6000-8Q" = {
          frameLimiter = false;
          vramMB = 7680;
        };
      };
      mdev = {
        device = "0000:05:00.0";
        vgpus = {
          nvidia-256.uuid = [ # 768MB (1Q)
            "b55a97d1-0235-4cd5-9107-14ef3e276817"
            "7a041175-dc01-4ab7-aad3-29de1962987f"
            "d094de44-9450-4e06-b89b-9faef4ac5d99"
            "790e93fc-b2cf-4911-8c85-7652f64816ec"
            "062a1895-11e8-4fc8-a811-f613157b1030"
            "e7da33a4-5214-45b4-b1b8-73d9d80b12c3"
            "e6362a4e-6fb5-441d-877f-4f2d025681d1"
            "926447eb-6fb0-44de-af03-e5de8d5cb1e9"
          ];
          nvidia-257.uuid = [ # 1536MB (2Q)
            "c18abdad-6052-426e-b5fe-575e49be3942"
            "adf982df-aa62-4b67-88c3-7b72227e6b44"
            "14587a10-f278-42bb-80a4-616d46877215"
            "60d4161e-ab0b-4404-8d6c-092fcff5f5bc"
          ];
          nvidia-259.uuid = [ # 3584MB (4Q)
            "0082a0e0-16b2-40c0-a44f-eb93b4b4e5ac"
            "6b556be7-54de-43ce-804a-64313b2a3ae9"
          ];
          nvidia-260.uuid = [ # 5632MB (6Q)
            "9ff52e10-a771-4a03-b25f-bce2633f8380"
          ];
          nvidia-261.uuid = [ # 7680MB (8Q)
            "0cc09914-633b-4977-be20-ab567a9dc62e"
          ];
        };
      };
    };
  };
  environment.variables.__RM_NO_VERSION_CHECK = "1";
  environment.variables.KWIN_DRM_DEVICES = "/dev/amdgpu-card";

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
        address = [ "172.16.1.10/16" ];
        routes = [{
          Gateway = "172.16.0.1";
          Destination = "0.0.0.0/0";
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
      "172.16.0.100" = [ "TEAL" ]; # 10 Gigabit Link
    };
    firewall = {
      enable = false;
      checkReversePath = false; # Wireguard
    };
  };

  # Performance
  powerManagement.cpuFreqGovernor = "performance";

  # Power
  power.ups = {
    enable = true;
    upsmon.monitor."CP1500PFCLCDa".user = "upsmon";
    users.upsmon = {
      passwordFile = builtins.toString (pkgs.writeText "nut-password" "ShimmerIsTheBest");
      upsmon = "primary";
    };
    ups.CP1500PFCLCDa = {
      driver = "usbhid-ups";
      description = "CyberPower CP1500PFCLCDa";
      port = "auto";
      directives = [
        "vendorid = 0764"
        "productid = 0601"
      ];
    };
  };

  # VFIO
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
    SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:03:00.0", SYMLINK+="amdgpu-card"
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
  # Bees is more of an IO hastle than it's worth
  #services.beesd.filesystems = {
  #  system = {
  #    spec = "/home";
  #    hashTableSizeMB = 2048;
  #    verbosity = "crit";
  #    extraOptions = [ "--thread-count" "4" "--loadavg-target" "5.0" ];
  #  };
  #};

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
  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName; # The machine-id is supposed to be secret, but we don't care. 
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
        "/var/lib/libvirt" # Keep KVM junk
        "/var/lib/upower" # Keep UPower junk
        { directory = "/var/lib/syncthing"; user = "collin"; group = "collin"; } # Syncthing
        "/var/lib/NetworkManager" # I like using WiFi
        { directory = "/var/lib/private/ollama"; user = "ollama"; group = "ollama"; } # Ollama
      ];
      files = [
        "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
        "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
      ];
    };
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
