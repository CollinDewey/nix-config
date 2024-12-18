{ ... }:
let
  defaultOptsSSD = [ "compress-force=zstd:1" "noatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      OS = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1MiB";
              end = "1GiB";
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
        # May need to replace with btrfs snapshots if I use more than 8G?
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=8G" "mode=755" ];
      };
    };
  };
}
