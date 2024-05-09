{ ... }:
{
  disk = {
    sda = {
      type = "disk";
      device = "/dev/disk/by-id/ata-TS128GMTS400_C819561042";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          Linux = {
            name = "Linux";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              subvolumes = {
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" ];
                };
                "/tmp" = {
                  mountpoint = "/tmp";
                  # /tmp gets cleared on boot
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
  nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [ "defaults" "size=3G" "mode=755" ];
    };
  };
}