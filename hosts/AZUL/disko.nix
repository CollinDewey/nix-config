{ ... }:
let
  defaultOptsSSD = [ "compress-force=zstd:1" "noatime" "nodiratime" ];
in
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
                  mountOptions = defaultOptsSSD;
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = defaultOptsSSD;
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = defaultOptsSSD;
                };
                "/tmp" = {
                  mountpoint = "/tmp";
                  # /tmp gets cleared on boot
                  mountOptions = defaultOptsSSD;
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
