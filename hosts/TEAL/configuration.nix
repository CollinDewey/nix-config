{ pkgs, ... }:
let
  nfs_opts_rw = "rw,nohide,insecure,no_subtree_check,no_root_squash,async";
  nfs_opts_ro = "ro,nohide,insecure,no_subtree_check,no_root_squash,async";
in
{
  services = {
    netdata.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        / 172.16.1.0/24(${nfs_opts_rw},crossmnt) 10.133.0.0/16(${nfs_opts_rw},crossmnt)
        /var/lib/libvirt 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /var/lib/libvirt/images_hdd 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /snapshots 172.16.1.0/24(${nfs_opts_ro}) 10.133.0.0/16(${nfs_opts_ro})
        /services 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /cyber 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /storage 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /network_share/Global 172.16.0.0/12(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /network_share/CMD 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /network_share/BLD 172.16.2.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /network_share/CEV 172.16.3.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /network_share/AMD 172.16.4.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
      '';
    };
  };
}
