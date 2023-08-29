{ config, lib, pkgs, ... }:

{
  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "mitigations=off" "retbleed=off" "iommu=soft" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;

  # Networking
  time.timeZone = "America/Louisville";
  networking = {
    hostName = "TEAL";
    nameservers = [ "172.16.0.3" ];
    defaultGateway = "172.16.0.1";
    useDHCP = false;
    firewall.enable = false;
    firewall.checkReversePath = false;
    interfaces = {
      enp6s0.useDHCP = true;
      enp2s0f1 = {
        ipv4.addresses = [{
          address = "10.133.133.1";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
    };
  };

  # State
  system.stateVersion = "21.05";

  # Disks
  swapDevices = [{ device = "/swapfile"; size = 8192; }];
  boot.tmp.cleanOnBoot = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/Linux";
    fsType = "ext4";
  };

  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs";
  };

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-label/Storage";
    fsType = "ext4";
  };

  fileSystems."/mnt/Other" = {
    device = "/dev/disk/by-label/Other";
    fsType = "ntfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/mnt/PI" = {
    device = "collin@172.16.0.3:/";
    options = [ "x-systemd.automount" "_netdev" "user" "idmap=user" "transform_symlinks" "identityfile=/home/collin/.ssh/id_rsa" "allow_other" "reconnect" "ServerAliveInterval=2" "ServerAliveCountMax=2" "compression=no" "cipher=chacha20-poly1305@openssh.com" "default_permissions" "uid=1000" "gid=1000" ];
    fsType = "fuse.sshfs";
  };

  fileSystems."/mnt/BROWN" = {
    device = "collin@BROWN:/";
    options = [ "x-systemd.automount" "_netdev" "user" "idmap=user" "transform_symlinks" "identityfile=/home/collin/.ssh/id_rsa" "allow_other" "reconnect" "ServerAliveInterval=15" "ServerAliveCountMax=3" "default_permissions" "uid=1000" "gid=1000" ];
    fsType = "fuse.sshfs";
  };

  fileSystems."/mnt/Block" = {
    device = "collin@BROWN:/mnt/Block";
    options = [ "x-systemd.automount" "_netdev" "user" "idmap=user" "transform_symlinks" "identityfile=/home/collin/.ssh/id_rsa" "allow_other" "reconnect" "ServerAliveInterval=15" "ServerAliveCountMax=3" "default_permissions" "uid=1000" "gid=1000" ];
    fsType = "fuse.sshfs";
  };

  # Users
  users.mutableUsers = false;

  # Sops Key File Location
  sops.age.keyFile = "/root/sops-key.txt";
}
