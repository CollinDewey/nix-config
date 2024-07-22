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
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" ];
    kernelParams = lib.mkDefault [ "mitigations=off" "retbleed=off" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Filesystems
    supportedFilesystems = [ "ntfs" ];

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
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
  networking = {
    hostName = "AZUL";
    networkmanager.enable = true;
    firewall.enable = false;
  };

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
      hashTableSizeMB = 16;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "1" "--loadavg-target" "5.0" ];
    };
  };

  # Partitioning
  disko.devices = import ./disko.nix;

  # Video
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver # VAAPI
      libvdpau-va-gl # No idea if this is needed
      intel-media-sdk # QSV
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # Audio
  services.pipewire.enable = true;

  # NFS
  #fileSystems = {
  #  "/mnt/storage" = {
  #    device = "TEAL:/storage";
  #    fsType = "nfs";
  #    options = nfs_opts;
  #  };
  #};

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log" # Keep system logs
      { directory = "/var/lib/syncthing"; user = "collin"; group = "collin"; }
      { directory = "/var/lib/klipper"; user = "klipper"; group = "klipper"; }
      { directory = "/var/lib/moonraker"; user = "klipper"; group = "klipper"; }
      { directory = "/var/lib/private/klipper"; user = "klipper"; group = "klipper"; }
      { directory = "/var/lib/private/moonraker"; user = "klipper"; group = "klipper"; }
    ];
    files = [
      "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
      "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
      "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
      "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
      "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
    ];
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/private 0700 0000 0000 -"
  ];
  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}
