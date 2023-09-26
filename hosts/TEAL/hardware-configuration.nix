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
    kernelParams = [ "mitigations=off" "retbleed=off" "intel_iommu=on" "iommu=pt" "vfio_pci.ids=8086:1521,103c:8157" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
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
          address = "10.133.133.1";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
      enp5s0f0.useDHCP = true;
    };
    macvlans."macvlan" = {
      interface = "enp5s0f0";
      mode = "vepa";
    };
  };

  # State
  system.stateVersion = "23.05";

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
      extraOptions = [ "--loadavg-target" "60.0" ];
    };
    raid = {
      spec = "/snapshots";
      hashTableSizeMB = 4096;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "60.0" ];
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
        { file = "/home/collin/.zsh_history"; parentDirectory = { user = "collin"; group = "collin"; }; } # Full tmpfs home
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
  systemd.tmpfiles.rules = [
    "L /persist/hiddenRoot - - - - /.hidden"
    "d /home/collin/.config 0755 1000 1000 -"
  ];

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
