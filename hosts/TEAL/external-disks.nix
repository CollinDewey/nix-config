{ config, lib, ... }:
let
  defaultOpts = [ "compress=zstd" "noatime" "nodiratime" ];
in
{
  config = lib.mkIf (config.specialisation != {}) {
    fileSystems = {
      "/snapshots" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=snapshots" ];
      };
      "/cyber" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=cyber" ];
      };
      "/vm_storage" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=virtualization_hdd" ];
      };
      "/network_share" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOpts ++ [ "subvol=network_share" ];
      };
    };
  };
}