{ config, lib, ... }:
let
  defaultOpts = [ "compress=zstd" "noatime" "nodiratime" ];
in
{
  config = lib.mkIf (config.specialisation != {}) {
    fileSystems = {
      "/var/log/syncthing" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=sync" ];
      };
      "/snapshots" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=snapshots" ];
      };
      "/var/lib/libvirt/images_hdd" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=virtualization_hdd" ];
      };
      "/mnt/Storage" = {
        device = "/dev/disk/by-label/Storage";
        fsType = "ext4";
      };
    };
  };
}