{ pkgs, inputs, lib, ... }:
let
  # Override openocd with latest version from GitHub
  openocd = pkgs.openocd.overrideAttrs (oldAttrs: {
    version = "unstable-2025-01-15";

    src = pkgs.fetchFromGitHub {
      owner = "openocd-org";
      repo = "openocd";
      rev = "587c7831033cda2c5aa683d18a183df52b631004";
      hash = "sha256-nqu0fUI0M/SJtKovcLgBSDgiApE3JSemqOujyqcSz5I=";
    };

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.autoreconfHook ];
  });
in
{
  # Master's Project
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-uofl" ];
    externalInterface = "enp1s0";
  };

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", ATTRS{serial}=="M4321005", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="hsmA", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", ATTRS{serial}=="M4324322", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="hsmB", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="80c2", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="toA", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="80c2", ENV{ID_USB_INTERFACE_NUM}=="02", SYMLINK+="toB", MODE="0666"
  '';

  containers = {
    uofl = {
      autoStart = false;
      ephemeral = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";
      forwardPorts = [
        {
          containerPort = 4566;
          hostPort = 4566;
          protocol = "tcp";
        }
        {
          containerPort = 24548;
          hostPort = 24548;
          protocol = "tcp";
        }
      ];
      additionalCapabilities = [
        "all" # Docker (Yes this compromises the security of the container completely)
      ];
      config = { pkgs, lib, config, ... }: {
        imports = [
          ../../modules/zsh.nix
          ../../modules/sanity.nix
          inputs.nix-index-database.nixosModules.nix-index
          inputs.vscode-server.nixosModules.default
        ];
        
        modules = {
          zsh.enable = true;
          sanity.enable = true;
        };
        services.envfs.enable = lib.mkForce false; # This would cause systemd to throw "[!!!!!!] Refusing to run in unsupported environment where /usr/ is not populated."
        
        services.openssh = {
          enable = true;
          ports = [ 24548 ];
          settings = {
            PermitRootLogin = lib.mkForce "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            LogLevel = "VERBOSE";
          };
        };
        
        services.vscode-server = {
          enable = true;
          enableFHS = true;
        };

        systemd.services.create-device-symlinks = { # Stupid
          wantedBy = [ "multi-user.target" ];
          script = ''
            ln -sf /dev/hsmA /dev/ttyACM0
            ln -sf /dev/hsmB /dev/ttyACM1
            ln -sf /dev/toA /dev/ttyACM2
            ln -sf /dev/toB /dev/ttyACM3
            chmod 666 /dev/bus/usb/003/*
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };

        services.code-server = {
          enable = true;
          user = "ectf";
          host = "0.0.0.0";
          port = 4566;
          disableTelemetry = true;
          disableWorkspaceTrust = true;
          disableUpdateCheck = true;
          hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$MnFscWo4dHh1d094YjRoS08yd01nY0NHamxNPQ$cTROL0UHOveImUtpYvt6hflLni43xeKaH8kDGbB/JW4";
          extraEnvironment = {
            EXTENSIONS_GALLERY = ''{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl":"https://marketplace.visualstudio.com/items","controlUrl":"","recommendationsUrl":""}'';
          };
        };
        #nix-shell -p autoPatchelfHook systemd stdenv.cc.cc --run  'autoPatchelf /home/collin/ectf/.local/share/code-server/extensions/ms-vscode.vscode-serial-monitor-0.13.1/dist/node_modules/usb/prebuilds/linux-x64/node.napi.glibc.node'

        users.groups.ectf.gid = 1000;
        users.users.ectf = {
          group = "ectf";
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "dialout" "docker" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+WbC25zpb/rFy3FZdcLSr6QrwUaxhu+RPDW13wrIWF"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFIr0tnR5LODmw5dEiKNouYB0ajeFHT3TdbF5XxR+Lfq"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7ln0qNr1GVq+LjfdIMeu4aJQiH8EUIN1dHq/cIM2sq"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwt3w++zPw6kN1EmoSMJyVNTdhzybJ3956/AWWI4n2B"
          ];
        };

        programs.zsh.shellAliases = {
          ectf = "uvx ectf";
          gdb = "pwndbg";
        };

        virtualisation.docker.enable = true;

        programs.nix-index-database.comma.enable = true;
        programs.command-not-found.enable = false;

        systemd.user.services.auto-fix-vscode-server = {
          enable = true;
          wantedBy = [ "default.target" ];
        };

        nix = {
          settings = {
            experimental-features = "nix-command flakes";
            trusted-users = [ "@wheel" ];
          };
          registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
          nixPath = (lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry) ++ [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
        };

        environment.systemPackages = with pkgs; [
          zoxide
          htop
          fastfetch
          git
          nano
          wget
          curl
          aria2
          eza

          gnumake
          uv
          openocd
          inputs.pwndbg.packages.x86_64-linux.default
        ];

        users.defaultUserShell = pkgs.zsh;
        
        networking.firewall.enable = false;
        system.stateVersion = "25.05";
      };
      allowedDevices = [
        {
          node = "/dev/hsmA";
          modifier = "rwm";
        }
        {
          node = "/dev/hsmB";
          modifier = "rwm";
        }
        {
          node = "/dev/toA";
          modifier = "rwm";
        }
        {
          node = "/dev/toB";
          modifier = "rwm";
        }
        
      ] ++ builtins.genList (i: { node = "/dev/bus/usb/003/${lib.fixedWidthString 3 "0" (toString (i + 1))}"; modifier = "rwm"; }) 99;
      bindMounts = {
        "/home/ectf" = {
          hostPath = "/home/collin/ectf";
          isReadOnly = false;
        };
        "/dev/hsmA" = {
          hostPath = "/dev/hsmA";
          isReadOnly = false;
        };
        "/dev/hsmB" = {
          hostPath = "/dev/hsmB";
          isReadOnly = false;
        };
        "/dev/toA" = {
          hostPath = "/dev/toA";
          isReadOnly = false;
        };
        "/dev/toB" = {
          hostPath = "/dev/toB";
          isReadOnly = false;
        };
        "/var/lib/docker" = {
          hostPath = "/home/collin/ctfdocker";
          isReadOnly = false;
        };
        "/dev/bus/usb/003" = {
          hostPath = "/dev/bus/usb/003";
          isReadOnly = false;
        };
        "/etc/ssh/ssh_host_ed25519_key" = {
          hostPath = "/etc/ssh/ssh_host_ed25519_key";
          isReadOnly = true;
        };
        "/etc/ssh/ssh_host_ed25519_key.pub" = {
          hostPath = "/etc/ssh/ssh_host_ed25519_key.pub";
          isReadOnly = true;
        };
        "/etc/ssh/ssh_host_rsa_key" = {
          hostPath = "/etc/ssh/ssh_host_rsa_key";
          isReadOnly = true;
        };
        "/etc/ssh/ssh_host_rsa_key.pub" = {
          hostPath = "/etc/ssh/ssh_host_rsa_key.pub";
          isReadOnly = true;
        };
      };
    };
  };
}
