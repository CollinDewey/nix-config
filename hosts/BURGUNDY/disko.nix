{ ... }:
{
  disk = {
    vda = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            type = "partition";
            start = "1MiB";
            end = "1GiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "Linux";
            type = "partition";
            start = "1GiB";
            end = "100%";
            content = {
              type = "btrfs";
              extraArgs = "-f"; # Override existing partition
              subvolumes = {
                #"/root" = {
                #  mountpoint = "/";
                #  mountOptions = [ "compress=zstd" ];
                #};
                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                };
                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/persist" = {
                  mountOptions = [ "compress=zstd" ];
                };
                "/tmp" = { # /tmp gets cleared on boot
                  mountOptions = [ "noatime" ];
                };
              };
            };
          }
        ];
      };
    };
  };
  nodev = {
    "/" = { # May need to replace with btrfs snapshots if I use more than 2G?
      fsType = "tmpfs";
      mountOptions = [ "defaults" "size=2G" "mode=755" ];
    };
  };
}