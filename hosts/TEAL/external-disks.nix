{ config, lib, ... }:
let
  defaultOptsHDD = [ "compress-force=zstd" "noatime" "nodiratime" ];
in
{
  config = lib.mkIf (config.specialisation != { }) {
    fileSystems = {
      "/snapshots" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOptsHDD ++ [ "subvol=snapshots" ];
      };
      "/cyber" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOptsHDD ++ [ "subvol=cyber" ];
      };
      "/vm_storage" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOptsHDD ++ [ "subvol=virtualization_hdd" ];
      };
      "/network_share" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOptsHDD ++ [ "subvol=network_share" ];
      };
      "/photos" = {
        device = "/dev/bcache0";
        fsType = "btrfs";
        options = defaultOptsHDD ++ [ "subvol=photos" ];
      };
    };
  };
}
