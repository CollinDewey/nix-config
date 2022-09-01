{ config, pkgs, lib, ... }:
{

  # Boot
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "mitigations=off" "retbleed=off" ];
    kernelPackages = pkgs.linuxPackages_xanmod;
    cleanTmpDir = true;
  };
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = "performance";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking = {
    hostName = "BURGUNDY";
    networkmanager.enable = true;
    wireless.iwd.enable = true;
    networkmanager.wifi.backend = "iwd";
  };

  # Misc
  time.hardwareClockInLocalTime = true; # Windows is silly and I need it for school

  # Drives
  fileSystems."/" = {
    device = "/dev/disk/by-label/Linux";
    fsType = "ext4";
  };

  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  services.fstrim.enable = true;

  # Video
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''Option         "metamodes" "DP-0.1: nvidia-auto-select +1920+1026 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.2: 1920x1080_60_0 +2288+0 {viewportout=1824x1026+48+27, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.3: 1920x1080 +0+1026 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"'';
  hardware.nvidia.prime = {
    #offload.enable = true;
    sync.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    amdgpuBusId = "PCI:6:0:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Specializations
  specialisation = {
    integrated.configuration = {
      system.nixos.tags = [ "Integrated" ];
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce true;
      powerManagement.enable = true;
      services.power-profiles-daemon.enable = lib.mkForce false;
      services.tlp = {
        enable = true;
        settings = {  
          CPU_SCALING_GOVERNOR_ON_AC="performance";
          CPU_SCALING_GOVERNOR_ON_BAT="powersave";
        };
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}