{ config, ... }:
{
  # Enable Docker/Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enableNvidia = true;
}