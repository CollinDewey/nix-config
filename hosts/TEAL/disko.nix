{ ... }:
let
  defaultOpts = [ "compress=zstd" "noatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1";
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
                extraArgs = [ "-f" ]; # Override existing partition (probably dangerous?)
                subvolumes = {
                  "/nix" = { # The one and only Nix
                    mountpoint = "/nix";
                    mountOptions = defaultOpts;
                  };
                  "/persist" = { # Holds files and folders I want
                    mountpoint = "/persist";
                    mountOptions = defaultOpts;
                  };
                  "/clearable" = { # This data can be wiped and is deemed not important
                    mountpoint = "/clearable";
                    mountOptions = defaultOpts;
                  };
                  "/virtualization" = { # Virtual Machine images + configurations
                    mountpoint = "/var/lib/libvirt";
                    mountOptions = defaultOpts;
                  };
                  "/services" = { # Storage for multiple services
                    mountpoint = "/services";
                    mountOptions = defaultOpts;
                  };
                };
              };
            };
          };
        };
      };
      hdd = {
        type = "disk";
        device = "pci-0000:00:11.4-ata-1";
        content = {
          type = "gpt";
          partitions = {
            Storage = {
              name = "Storage";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition (probably dangerous?)
                subvolumes = {
                  "/storage" = {
                    mountpoint = "/storage";
                    mountOptions = defaultOpts;
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
        # May need to replace with btrfs snapshots if I use more than 32G?
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=32G" "mode=755" ];
      };
    };
  };
}
