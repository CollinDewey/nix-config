{ ... }:
{
  virtualisation.vmVariant.virtualisation = {
    diskSize = 16384;
    memorySize = 8192;
    cores = 8;
  };

  time.timeZone = "America/Kentucky/Louisville";
  networking.hostName = "VM";
}
