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
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usb_storage" "sd_mod" ];
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
    kernelModules = [ "kvm-amd" "uinput" "kvmfr" ];
    extraModprobeConfig = ''options kvmfr static_size_mb=64'';
    kernelParams = [ "mitigations=off" "retbleed=off" ];
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
    nvidia.open = true;
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
    screenSection = ''Option "metamodes" "DP-0.2: 1920x1080 +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNC=Off}, DP-0.1: nvidia-auto-select +1920+1080 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNC=Off}, DP-0.3: 1920x1080 +0+1080 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNC=Off}"'';
  };
  hardware.nvidia.forceFullCompositionPipeline = true;

  # Networking
  time.timeZone = "America/Louisville";
  #time.hardwareClockInLocalTime = true; # Windows is silly and I need it for work/school
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
      services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = true;
      powerManagement.enable = true;
      services.power-profiles-daemon.enable = lib.mkForce false;
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        };
      };
    };
    reversePrime.configuration = {
      system.nixos.tags = [ "ReversePrime" ];
      services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
      hardware.nvidia = {
        prime.sync.enable = lib.mkForce false;
        prime.reverseSync.enable = true;
        modesetting.enable = true;
      };
    };
  };

  # VFIO
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
  '';
  environment.etc."looking-glass-client.ini".text = ''
    [app]
    shmFile=/dev/kvmfr0
  '';
  virtualisation.libvirtd.qemuVerbatimConfig = ''
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
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "1" "--loadavg-target" "3.0" ];
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
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log" # Keep system logs
      "/var/lib/docker" # Keep Docker junk
      "/var/lib/libvirt" # Keep KVM junk
      "/var/lib/iwd" # I like using WiFi
      "/var/lib/NetworkManager" # I like using WiFi
      "/etc/nixos" # Not nuke my configuration
      "/etc/NetworkManager/system-connections" # I like using WiFi
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
