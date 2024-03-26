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
    kernelPackages = pkgs.linuxPackages_xanmod;
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
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    opengl.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.rocm-runtime
      amdvlk
    ];
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

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
      # Syncthing
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
      checkReversePath = false; # Wireguard
    };
  };



  # Video
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" "displaylink" ];
  #services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.nvidia.prime.offload.enable = true;
  environment.variables.__RM_NO_VERSION_CHECK = "1";
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
  services.desktopManager.plasma6.enable = true; # Temporary until 24.05 releases

  specialisation = {
    dedicated.configuration = {
      system.nixos.tags = [ "Dedicated" ];
      powerManagement.cpuFreqGovernor = lib.mkForce "performance";
      services.power-profiles-daemon.enable = lib.mkForce true;
      services.tlp.enable = lib.mkForce false;
      services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
      hardware.nvidia.forceFullCompositionPipeline = true;
      hardware.nvidia.prime = {
        offload.enable = lib.mkForce false;
        sync.enable = true;
      };
    };

    reversePrime.configuration = {
      system.nixos.tags = [ "ReversePrime" ];
      hardware.nvidia = {
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
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
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
      "/var/lib/syncthing" # Syncthing
      "/var/lib/NetworkManager" # I like using WiFi
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
