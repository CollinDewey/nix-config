{ ... }:
{
  virtualisation.vmVariant.virtualisation = {
    diskSize = 16384;
    memorySize = 8192;
    cores = 8;
  };

  boot.loader.systemd-boot.enable = true; # Make eval not complain about a lack of bootloader
  fileSystems."/".device = "/dev/disk/by-label/nixos";

  time.timeZone = "America/Kentucky/Louisville";
  networking.hostName = "VM";
}
