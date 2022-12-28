# Nix Config

A personal Nix configuration across my computers running Nix and NixOS.


## NixOS installation
- Load into the NixOS Live Installation Image
- Set a password for the nixos account using `passwd nixos`
- Clone and enter the repo using `git clone`
- Setup disko disks using
```
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" -- --mode create hosts/{hostname}/disko.nix
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" -- --mode mount hosts/{hostname}/disko.nix
```
- Copy the sops-nix age key file using sftp to the specified location
- Install with `sudo nixos-install --no-root-passwd --flake github:LegitMagic/nix-config#VM`