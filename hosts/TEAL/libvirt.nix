{ inputs, ... }:

let
  inherit (inputs) nixvirt;
  storage_dir = "/vm_storage";
in
{
  imports = [
    nixvirt.nixosModules.default
  ];

  # More stuff here eventually
  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = true; # Win 11 TPM
    connections."qemu:///system" =
      {
        pools = [
          {
            definition = nixvirt.lib.pool.writeXML {
              name = "default";
              uuid = "5a2a41f9-a41d-407a-8762-cfc116a10398";
              type = "dir";
              target = { path = "${storage_dir}"; };
            };
          }
        ];
      };
  };
}
