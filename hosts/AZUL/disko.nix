{ ... }:
{
  disk = {
    sda = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-UDSS_UD2CSEDT300-512G_TUSMA241JX00443";
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