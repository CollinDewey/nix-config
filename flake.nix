{
  description = "Collin's Nix Configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.home-manager.follows = "home-manager-stable";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, impermanence, nixos-hardware, sops-nix, nix-index-database, darwin, disko, home-manager-unstable, home-manager-stable, plasma-manager, android-nixpkgs, nixos-generators, deploy-rs, ... }@inputs: {

    nixosConfigurations = {
      CYAN = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/CYAN/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/CYAN/hardware-configuration.nix

          {
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
          ./users
          ./users/collin
          ./users/shimmer
          home-manager-unstable.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                android-nixpkgs.hmModule
                ./home

                # Computer Specific Config
                ./hosts/CYAN/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                communication.enable = true;
                cyber.enable = true;
                gaming.enable = true;
                klipper.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                office.enable = true;
                plasma.enable = true;
                plover.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "23.11";
            };

            home-manager.users.shimmer = {
              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                ./home

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/shimmer/home.nix
              ];

              modules = {
                communication.enable = true;
                gaming.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "23.11";
            };
          }
        ];
      };

      BURGUNDY = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          #./overlays/android-sdk.nix
          ./modules
          ./hosts/BURGUNDY/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/BURGUNDY/hardware-configuration.nix

          {
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
          ./users
          ./users/collin
          ./users/shimmer
          home-manager-unstable.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                android-nixpkgs.hmModule
                ./home
                #./home/android-sdk.nix

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                #android-sdk.enable = true;
                communication.enable = true;
                cyber.enable = true;
                gaming.enable = true;
                klipper.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                office.enable = true;
                plasma.enable = true;
                plover.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "22.11";
            };

            home-manager.users.shimmer = {
              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                ./home

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/shimmer/home.nix
              ];

              modules = {
                communication.enable = true;
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
            modules = {
              ssh.enable = true;
              virtualisation = {
                docker = true;
                libvirt = true;
                nvidia = false;
              };
              zsh.enable = true;
            };
          }

          # User
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
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
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
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
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
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
      };

      RUBY = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/RUBY/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
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
          home-manager-unstable.darwinModules.home-manager
          {
            home-manager.users.collin = {
              imports = [
                ./home
                ./users/collin/home.nix
                ./hosts/COPPER/home.nix
                plasma-manager.homeManagerModules.plasma-manager
                nix-index-database.hmModules.nix-index
              ];

              modules = {
                zsh.enable = true;
              };

              home.stateVersion = "22.11";
            };
          }
        ];
      };
    };

    packages.x86_64-linux = {
      ISO = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager-unstable.nixosModules.home-manager
          ./config
          ./config/home.nix
          ./hosts/ISO/configuration.nix
          ./overlays
          ./modules
          {
            modules = {
              plasma.enable = true;
              ssh.enable = true;
              zsh.enable = true;
            };

            home-manager.users.nixos = {
              imports = [
                plasma-manager.homeManagerModules.plasma-manager
                ./home
              ];
              modules = {
                communication.enable = true;
                lock.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };
              home.stateVersion = "22.11";
            };
          }
        ];
        format = "install-iso";
      };
    };

    packages.aarch64-linux = {
      VIRIDIAN_IMAGE = nixos-generators.nixosGenerate {
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
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
        format = "sd-aarch64";
      };
    };

    deploy = {
      user = "root";
      remoteBuild = true;

      # deploy-rs#78
      magicRollback = false;
      sshOpts = [ "-t" ];

      nodes = {
        # Keeps failing with "too many root sets, look into that"
        TEAL = {
          hostname = "TEAL";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.TEAL;
        };

        VIRIDIAN = {
          hostname = "VIRIDIAN";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.VIRIDIAN;
        };

        BROWN = {
          hostname = "brown.terascripting.com";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.BROWN;
        };

        SCARLET = {
          hostname = "scarlet.terascripting.com";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.SCARLET;
        };

        RUBY = {
          hostname = "ruby.terascripting.com";
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.RUBY;
        };
      };
    };

    # Check is too demanding
    #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
