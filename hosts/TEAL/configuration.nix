{ pkgs, ... }:
let
  nfs_opts_rw = "rw,nohide,insecure,no_subtree_check,no_root_squash,async";
  nfs_opts_ro = "ro,nohide,insecure,no_subtree_check,no_root_squash,async";
in
{
  services = {
    jellyfin.enable = true;
    netdata.enable = true;
    syncthing = {
      enable = true;
      user = "collin";
      guiAddress = "0.0.0.0:8384";
      dataDir = "/services/syncthing";
    };

    nfs.server = {
      enable = true;
      exports = ''
        / 172.16.1.0/24(${nfs_opts_rw},crossmnt) 10.133.0.0/16(${nfs_opts_rw},crossmnt)
        /mnt/Storage 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /var/lib/libvirt 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /var/lib/libvirt/images_hdd 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /snapshots 172.16.1.0/24(${nfs_opts_ro}) 10.133.0.0/16(${nfs_opts_ro})
        /services 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
        /cyber 172.16.1.0/24(${nfs_opts_rw}) 10.133.0.0/16(${nfs_opts_rw})
      '';
    };
  };
}
