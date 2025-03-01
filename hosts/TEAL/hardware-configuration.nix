{ config, lib, pkgs, inputs, ... }:

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
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "kvm-intel" "vfio_pci" "vfio" ];
    kernelParams = [ "mitigations=off" "retbleed=off" "intel_iommu=on" "iommu=pt" ];
    kernelPackages = pkgs.linuxPackages_6_6;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Boot
    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    initrd.systemd.emergencyAccess = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Video
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.vgpu = {
    enable = true;
    vgpu_driver_src.url = "https://teal.terascripting.com/internal/NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.55.zip";
    profile_overrides = {
      "GRID RTX6000-1Q".frameLimiter = false;
      "GRID RTX6000-2Q".frameLimiter = false;
      "GRID RTX6000-4Q" = {
        frameLimiter = false;
        vramMB = 3584;
      };
      "GRID RTX6000-8Q" = {
        frameLimiter = false;
        vramMB = 7680;
      };
    };
    mdev = {
      device = "0000:04:00.0";
      vgpus = {
        nvidia-261.uuid = [ "fbaf3b24-a228-4121-bdeb-906ce8bbfabc" "470cfb92-8a6e-438b-886d-bc29395e96fa" ];
      };
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Virtualisation
  virtualisation.spiceUSBRedirection.enable = true;

  # Networking
  time.timeZone = "America/Louisville";
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    links = {
      "10-ten-unused" = {
        matchConfig.PermanentMACAddress = "a0:36:9f:54:a2:dc";
        linkConfig.Name = "ten0";
      };
      "10-ten-lan" = {
        matchConfig.PermanentMACAddress = "a0:36:9f:54:a2:de";
        linkConfig.Name = "ten1";
      };
      "10-ten-opnsense" = {
        matchConfig.Path = "pci-0000:05:10.1";
        linkConfig.Name = "ten1v0";
      };
      "10-ten-blue" = {
        matchConfig.Path = "pci-0000:05:10.3";
        linkConfig.Name = "ten1v1";
      };
      "10-ten-winserver" = {
        matchConfig.Path = "pci-0000:05:10.5";
        linkConfig.Name = "ten1v2";
      };
      "10-ten-cerise" = {
        matchConfig.Path = "pci-0000:05:10.7";
        linkConfig.Name = "ten1v3";
      };
      "10-ten-cyberl" = {
        matchConfig.Path = "pci-0000:05:11.1";
        linkConfig.Name = "ten1v4";
      };
      "10-ten-cyberw" = {
        matchConfig.Path = "pci-0000:05:11.3";
        linkConfig.Name = "ten1v5";
      };
      "10-ten-spare0" = {
        matchConfig.Path = "pci-0000:05:11.5";
        linkConfig.Name = "ten1v6";
      };
      "10-ten-spare1" = {
        matchConfig.Path = "pci-0000:05:11.7";
        linkConfig.Name = "ten1v7";
      };
      "10-mobo" = {
        matchConfig.PermanentMACAddress = "0a:e0:af:ad:2a:57";
        linkConfig.Name = "mobo0";
      };
      "10-one-wan" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4c";
        linkConfig.Name = "quad0";
      };
      "10-one-lan" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4d";
        linkConfig.Name = "quad1";
      };
      "10-one-lan-opnsense" = {
        matchConfig.Path = "pci-0000:01:10.1";
        linkConfig.Name = "quad1v0";
      };
      "10-one-lan-homeassistant" = {
        matchConfig.Path = "pci-0000:01:10.5";
        linkConfig.Name = "quad1v1";
      };
      "10-one-quad2" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4e";
        linkConfig.Name = "quad2";
      };
      "10-one-quad3" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4f";
        linkConfig.Name = "quad3";
      };
    };
    networks = {
      "10-one-lan" = {
        matchConfig.Name = "quad1";
        networkConfig.DHCP = "ipv4";
      };
      "10-ten-lan" = {
        matchConfig.Name = "ten1";
        address = [ "172.26.0.100/16" ];
        routes = [{
          Gateway = "172.26.0.1";
          Destination = "172.26.0.0/16";
        }];
      };
    };
  };
  networking = {
    hostName = "TEAL";
    useDHCP = false;
    firewall.enable = false;
  };

  # Disks
  zramSwap.enable = true;

  # BTRFS Scrubbing
  services.btrfs.autoScrub = {
    fileSystems = [ "/persist" "/snapshots" ]; # Crosses subpartition bounds
    enable = true;
    interval = "weekly";
  };

  # BTRFS De-duplicating
  # Bees is more of an IO hastle than it's worth
  #services.beesd.filesystems = {
  #  ssd = {
  #    spec = "/persist";
  #    hashTableSizeMB = 512;
  #    verbosity = "crit";
  #    extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
  #  };
  #  raid = {
  #    spec = "/snapshots";
  #    hashTableSizeMB = 4096;
  #    verbosity = "crit";
  #    extraOptions = [ "--thread-count" "4" "--loadavg-target" "5.0" ];
  #  };
  #};

  # Specialisation
  specialisation = {
    NoMount.configuration = {
      system.nixos.tags = [ "NoMount" ];
    };
  };

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/clearable".neededForBoot = true;
  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName; # The machine-id is supposed to be secret, but we don't care. 
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      files = [
        { file = "/home/collin/.config/htop/htoprc"; parentDirectory = { user = "collin"; group = "collin"; }; } # Full tmpfs home
        "/home/collin/.zsh_history" # Keep shell history
        "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
        "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
      ];
      directories = [
        { directory = "/home/collin/.config/Moonlight Game Streaming Project"; user = "collin"; group = "collin"; }
      ];
    };
    "/clearable" = {
      hideMounts = true;
      enableWarnings = false;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
      ];
    };
  };
  systemd.tmpfiles.rules = [
    # bcache setup based on https://www.reddit.com/r/linux_gaming/tc3rkj
    "L /.hidden - - - - /persist/hiddenRoot"
    "d /home/collin 0755 1000 1000 - -"
    "d /home/collin/.config 0755 1000 1000 - -"
    "d /home/collin/.cache 0755 1000 1000 - -"
    "w /sys/block/bcache0/bcache/sequential_cutoff - - - - 3221225472" # 3GB
    "w /sys/block/bcache1/bcache/sequential_cutoff - - - - 3221225472" # 3GB
    "w /sys/block/bcache0/queue/read_ahead_kb - - - - 16384" # Read ahead 16K
    "w /sys/block/bcache1/queue/read_ahead_kb - - - - 16384" # Read ahead 16K
    "w /sys/block/bcache0/bcache/cache_mode - - - - writearound" # Read-only bcache
    "w /sys/block/bcache1/bcache/cache_mode - - - - writearound" # Read-only bcache
    "w /sys/fs/bcache/5864fdf7-afe2-454c-b694-903dc1899a02/congested_read_threshold_us - - - - 0" # No latency timeout
    "w /sys/class/net/quad1/device/sriov_numvfs - - - - 2"
    "w /sys/class/net/ten1/device/sriov_numvfs - - - - 8"
    "f /dev/shm/looking-glass 0660 root libvirtd -"
  ];

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
