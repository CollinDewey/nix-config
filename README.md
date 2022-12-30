# Nix Config

A personal Nix configuration across my computers running Nix and NixOS.

## NixOS installation
- Load into the NixOS Live Installation Image
- Clone and enter the repo using `git clone`
- If using disko[^1], setup disks using
```
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" -- --mode create hosts/{hostname}/disko.nix
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" -- --mode mount hosts/{hostname}/disko.nix
```
- Set a password for the nixos account using `passwd nixos`
- Copy the sops-nix age key file using sftp to the specified location
- Install with `sudo nixos-install --no-root-passwd --no-channel-copy --flake github:LegitMagic/nix-config#{hostname}`[^2]

[^1]: Disko actually has flake support which would let me avoid needing to clone the repo, but I couldn't get it working
[^2]: If using / on tmpfs, nixos-install creates a temporary directory for building. If you get an error from nixos-install about running out of space, give tmpfs more space. For example, `mount -o remount,size=8G /mnt`