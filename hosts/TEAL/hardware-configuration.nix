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
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "kvm-intel" "vfio_pci" "vfio" ];
    kernelParams = [ "mitigations=off" "retbleed=off" "intel_iommu=on" "iommu=pt" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Boot
    loader.systemd-boot.enable = true;
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

  # Networking
  time.timeZone = "America/Louisville";
  systemd.network.wait-online.anyInterface = true;
  networking = {
    hostName = "TEAL";
    nameservers = [ "172.16.0.3" ];
    defaultGateway = "172.16.0.1";
    useDHCP = false;
    firewall.enable = false;
    firewall.checkReversePath = false;
    interfaces = {
      enp5s0f1 = {
        ipv4.addresses = [{
          address = "10.133.133.2";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
      enp5s0f0.useDHCP = true;
      br0.useDHCP = true;
    };
    bridges.br0 = { interfaces = []; }; # VM Bridge
    bridges.br1 = { interfaces = []; }; # Container Bridge
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
      files = [
        #{ file = "/home/collin/.zsh_history"; parentDirectory = { user = "collin"; group = "collin"; }; } # Full tmpfs home
        { file = "/home/collin/.config/htop/htoprc"; parentDirectory = { user = "collin"; group = "collin"; }; } # Full tmpfs home
        "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
        "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
        "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
      ];
    };
    "/clearable" = {
      hideMounts = true;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
      ];
    };
  };
  systemd.tmpfiles.rules = [ # bcache setup based on https://www.reddit.com/r/linux_gaming/tc3rkj
    "L /persist/hiddenRoot - - - - /.hidden"
    "d /home/collin 0755 1000 1000 -"
    "d /home/collin/.config 0755 1000 1000 -"
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
