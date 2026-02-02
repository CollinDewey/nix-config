{ pkgs, lib, ... }:
let
  driver = (pkgs.linuxPackages.nvidiaPackages.mkDriver {
    version = "580.126.09";
    sha256_64bit = lib.fakeHash;
    sha256_aarch64 = "sha256-c5PEKxEv1vCkmOHSozEnuCG+WLdXDcn41ViaUWiNpK0=";
    openSha256 = lib.fakeHash;
    settingsSha256 = lib.fakeHash;
    persistencedSha256 = lib.fakeHash;
  }).override { libsOnly = true; kernel = null; };
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  system-graphics = {
    enable = true;
    package = driver;
    package32 = driver.lib32;
  };

  environment.etc."nix/nix.custom.conf".text = ''
    experimental-features = nix-command flakes auto-allocate-uids configurable-impure-env
    auto-allocate-uids = true
    require-sigs = false
    build-users-group = nixbld
    trusted-users = root @wheel
    substituters = https://cache.nixos.org/ https://cache.nixos-cuda.org https://pwndbg.cachix.org https://cache.numtide.com
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M= pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
  '';
}
