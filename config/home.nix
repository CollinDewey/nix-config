{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ # NixOS/nixpkgs#263764
    "electron-25.9.0"
  ];
}
