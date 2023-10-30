{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ # NixOS/nixpkgs#263764
    "electron-24.8.6"
  ];
}
