{ pkgs, ... }:
{
  services = {
    jellyfin.enable = true;
    netdata.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        / 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async,crossmnt)
        /mnt/Storage 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async)
        /var/lib/libvirt 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async)
        /var/lib/libvirt/images_hdd 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async)
        /snapshots 10.133.133.2(ro,nohide,insecure,no_subtree_check,no_root_squash,async)
        /services 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async)
        /cyber 10.133.133.2(rw,nohide,insecure,no_subtree_check,no_root_squash,async)
      '';
    };
  };
}
