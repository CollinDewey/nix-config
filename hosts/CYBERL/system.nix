{ pkgs, ... }:
let
  driver = (pkgs.linuxPackages.nvidiaPackages.mkDriver {
    version = "550.90.07";
    sha256_64bit = "sha256-Uaz1edWpiE9XOh0/Ui5/r6XnhB4iqc7AtLvq4xsLlzM=";
    sha256_aarch64 = "sha256-uJa3auRlMHr8WyacQL2MyyeebqfT7K6VU0qR7LGXFXI=";
    openSha256 = "sha256-VLmh7eH0xhEu/AK+Osb9vtqAFni+lx84P/bo4ZgCqj8=";
    settingsSha256 = "sha256-sX9dHEp9zH9t3RWp727lLCeJLo8QRAGhVb8iN6eX49g=";
    persistencedSha256 = "sha256-qe8e1Nxla7F0U88AbnOZm6cHxo57pnLCqtjdvOvq9jk=";
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
    substituters = https://nix-community.cachix.org https://cuda-maintainers.cachix.org https://nix-community.cachix.org/ https://chaotic-nyx.cachix.org/ https://cache.nixos.org/
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=
  '';
}
