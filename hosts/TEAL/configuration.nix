{ pkgs, ... }:
let
  nfs_opts_rw = "rw,nohide,insecure,no_subtree_check,no_root_squash,async";
  nfs_opts_ro = "ro,nohide,insecure,no_subtree_check,no_root_squash,async";
in
{

  imports = [ ./libvirt.nix ];

  # State
  system.stateVersion = "23.05";

  # VGPU
  hardware.nvidia.vgpu.fastapi-dls = {
    enable = true;
    dataDir = "/services/fastapi-dls";
    port = 53492;
  };

  services = {
    netdata.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        / 172.16.1.0/24(${nfs_opts_rw},crossmnt) 172.26.1.0/24(${nfs_opts_rw},crossmnt)
        /snapshots 172.16.1.0/24(${nfs_opts_ro}) 172.26.1.0/24(${nfs_opts_ro})
        /services 172.16.1.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /cyber 172.16.1.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /storage 172.16.1.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /vm_storage 172.16.1.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /network_share/Global 172.16.0.0/12(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /network_share/CMD 172.16.1.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /network_share/BLD 172.16.2.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /network_share/CEV 172.16.3.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
        /network_share/AMD 172.16.4.0/24(${nfs_opts_rw}) 172.26.1.0/24(${nfs_opts_rw})
      '';
    };
  };
}
