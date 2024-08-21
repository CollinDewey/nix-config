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
  services.fstrim.enable = true;

  # Video
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.vgpu = {
    enable = true;
    profile_overrides = {
      "GRID RTX6000-1Q".frameLimiter = false;
      "GRID RTX6000-2Q".frameLimiter = false;
      "GRID RTX6000-4Q".frameLimiter = false;
    };
  };
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Networking
  time.timeZone = "America/Louisville";
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    links = {
      "10-lan" = {
        matchConfig.PermanentMACAddress = "a0:36:9f:54:a2:dc";
        linkConfig.Name = "ten0";
      };
      "10-cyan" = {
        matchConfig.PermanentMACAddress = "a0:36:9f:54:a2:de";
        linkConfig.Name = "ten1";
      };
      "10-mobo" = {
        matchConfig.PermanentMACAddress = "0a:e0:af:ad:2a:57";
        linkConfig.Name = "mobo0";
      };
      "10-quad0" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4c";
        linkConfig.Name = "quad0";
      };
      "10-quad1" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4d";
        linkConfig.Name = "quad1";
      };
      "10-quad2" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4e";
        linkConfig.Name = "quad2";
      };
      "10-quad3" = {
        matchConfig.PermanentMACAddress = "d4:f5:ef:44:30:4f";
        linkConfig.Name = "quad3";
      };
    };
    networks = {
      "10-lan" = {
        matchConfig.Name = "ten0";
        networkConfig.DHCP = "ipv4";
      };
      "10-cyan" = {
        matchConfig.Name = "ten1";
        linkConfig.MTUBytes = "9000";
        #address = [ "172.26.0.101/32" ];
        #routes = [{ 
        #  routeConfig = {
        #    Gateway = "172.26.0.100";
        #    Destination = "172.26.1.10/32";
        #  };
        #}];
        macvlan = [
          "macvlan0"
        ];
      };
      "20-macvlan0" = { # This is not setup correctly. I'll fix it later.
        matchConfig.Name = "macvlan0";
        linkConfig.MTUBytes = "9000";
        address = [ "172.26.0.100/16" ];
        routes = [{ 
          routeConfig = {
            Gateway = "172.26.0.1";
            Destination = "172.26.0.0/16";
          };
        }];
      };
    };
    netdevs = {
      "10-macvlan" = {
        netdevConfig = {
          Name = "macvlan0";
          Kind = "macvlan";
        };
        macvlanConfig.Mode = "bridge";
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
  services.beesd.filesystems = {
    ssd = {
      spec = "/persist";
      hashTableSizeMB = 512;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
    };
    raid = {
      spec = "/snapshots";
      hashTableSizeMB = 4096;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "4" "--loadavg-target" "5.0" ];
    };
  };

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
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      files = [
        { file = "/home/collin/.config/htop/htoprc"; parentDirectory = { user = "collin"; group = "collin"; }; } # Full tmpfs home
        "/home/collin/.zsh_history"# Keep shell history
        "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
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
  systemd.tmpfiles.rules = [ # bcache setup based on https://www.reddit.com/r/linux_gaming/tc3rkj
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
  ];

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
