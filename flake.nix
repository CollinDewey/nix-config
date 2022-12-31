{
  description = "Collin's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.11";
    impermanence.url = "github:nix-community/impermanence";
    
    nix-alien = { # Remove in favor of nix-index-database
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    #nix-index-database = { # Wait for Mic92/nix-index-database#34
    #  url = "github:Mic92/nix-index-database";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, impermanence, nix-alien, sops-nix, nix-darwin, disko, home-manager, plasma-manager, ... }@inputs: {
    
    nixosConfigurations = {
      BURGUNDY = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./hosts/BURGUNDY/hardware-configuration.nix

          {
            environment.systemPackages = with nix-alien.packages.x86_64-linux; [ nix-index-update ]; # Temporary
            modules = {
              plasma.enable = true;
              printing.enable = true;
              ssh.enable = true;
              virtualisation.enable = true;
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users/collin
          home-manager.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                ./home

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                communication.enable = true;
                cyber.enable = true;
                gaming.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "23.05";
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      COPPER = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./config
          ./config/home.nix
          ./users/collin/home.nix
          ./hosts/COPPER/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.collin = {
              imports = [
                ./home
                ./hosts/COPPER/home.nix
                plasma-manager.homeManagerModules.plasma-manager
              ];

              modules = {
                zsh.enable = true;
              };

              home.stateVersion = "23.05";
            };
          }
        ];
      };
    };
  };
}
