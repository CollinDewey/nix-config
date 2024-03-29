# Nix Config

A personal Nix configuration across my computers running Nix and NixOS.

## NixOS Live Media
- Nix needs to be installed
- Build an ISO by running the following command
```
nix build .#ISO --extra-experimental-features "nix-command flakes" --verbose --print-build-logs
```
- Resulting ISO will be in the ./result/iso

## NixOS installation
- Load into the NixOS Live Installation Image
- Clone and enter the repo using `git clone`
- If using disko[^1], setup disks using
```
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" -- --mode disko hosts/{hostname}/disko.nix
```
- Set a password for the nixos account using `passwd nixos`
- Copy the sops-nix age key file using sftp to the specified location
- Install with `sudo nixos-install --no-root-passwd --no-channel-copy --flake github:CollinDewey/nix-config#{hostname}`[^2]

[^1]: Disko actually has flake support which would let me avoid needing to clone the repo, but I couldn't get it working
[^2]: If using / on tmpfs, nixos-install creates a temporary directory for building. If you get an error from nixos-install about running out of space, give tmpfs more space. For example, `mount -o remount,size=8G /mnt`

## Displaylink
For BURGUNDY, the displaylink driver is downloaded using this command
```
nix-prefetch-url --name displaylink-580.zip https://www.synaptics.com/sites/default/files/exe_files/2023-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.8-EXE.zip
```