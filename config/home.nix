{ lib, config, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
}
