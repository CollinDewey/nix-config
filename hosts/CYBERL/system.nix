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
}
