{ config, lib, ... }:
let
  defaultOpts = [ "compress=zstd" "noatime" "nodiratime" ];
in
{
  config = lib.mkIf (config.specialisation != {}) {
    boot.swraid.mdadmConf = ''
      ARRAY /dev/md0 level=raid0 num-devices=2 metadata=1.2 name=TEAL:0 UUID=e64ff7f5:24973621:e2702cab:83fe4dfb
         devices=/dev/pci-0000:08:00.0-nvme-1,/dev/pci-0000:0a:00.0-nvme-1
    '';

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