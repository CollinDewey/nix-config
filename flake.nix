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

    darwin = {
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

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, impermanence, nix-alien, sops-nix, darwin, disko, home-manager, home-manager-stable, plasma-manager, android-nixpkgs, ... }@inputs: {
    
    nixosConfigurations = {
      BURGUNDY = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./overlays/android-sdk.nix
          ./modules
          ./hosts/BURGUNDY/configuration.nix

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
              virtualisation = {
                docker = true;
                libvirt = true;
                nvidia = true;
              };
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users
          ./users/collin
          home-manager.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                android-nixpkgs.hmModule
                ./home
                ./home/android-sdk.nix

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                android-sdk.enable = true;
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
      
      TEAL = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/TEAL/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/TEAL/hardware-configuration.nix

          {
            environment.systemPackages = with nix-alien.packages.x86_64-linux; [ nix-index-update ]; # Temporary
            modules = {
              plasma.enable = true;
              printing.enable = true;
              ssh.enable = true;
              virtualisation = {
                docker = true;
                libvirt = true;
                nvidia = true;
              };
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users
          ./users/collin
          home-manager-stable.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                ./home

                # Computer Specific Config
                ./hosts/TEAL/home.nix

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

              home.stateVersion = "22.11";
            };
          }
        ];
      };

      VIRIDIAN = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/VIRIDIAN/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/VIRIDIAN/hardware-configuration.nix

          {
            environment.systemPackages = with nix-alien.packages.aarch64-linux; [ nix-index-update ]; # Temporary
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users
          ./users/collin
        ];
      };

      BROWN = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/BROWN/hardware-configuration.nix

          {
            environment.systemPackages = with nix-alien.packages.aarch64-linux; [ nix-index-update ]; # Temporary
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users
          ./users/collin
        ];
      };

      SCARLET = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/SCARLET/hardware-configuration.nix

          {
            environment.systemPackages = with nix-alien.packages.aarch64-linux; [ nix-index-update ]; # Temporary
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          sops-nix.nixosModules.sops
          ./users
          ./users/collin
        ];
      };
    };

    darwinConfigurations = {
      COPPER = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./config
          ./config/home.nix
          ./hosts/COPPER/configuration.nix
          ./modules/zsh.nix
          {
            modules.zsh.enable = true;
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.users.collin = {
              imports = [
                ./home
                ./users/collin/home.nix
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
