{ config, lib, pkgs, inputs, ... }:

{
  # Imports
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ];

  # Boot
  boot = {
    # Kernel
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    extraModulePackages = with config.boot.kernelPackages; [ (kvmfr.overrideAttrs (_: { patches = ( pkgs.fetchpatch { url = "https://github.com/gnif/LookingGlass/commit/7305ce36af211220419eeab302ff28793d515df2.patch"; hash = "sha256-97nZsIH+jKCvSIPf1XPf3i8Wbr24almFZzMOhjhLOYk="; stripLen = 1; }); })) v4l2loopback ];
    kernelModules = [ "kvm-amd" "uinput" "kvmfr" ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    kernelParams = [ "mitigations=off" "retbleed=off" "initcall_blacklist=sysfb_init" ];
    kernelPackages = pkgs.linuxPackages_6_11;
    kernelPatches = [
      {
        name = "fan-profile-fix";
        patch = pkgs.fetchpatch {
          url = "https://lkml.org/lkml/diff/2024/6/9/155/1";
          hash = "sha256-o2YWx1m4Fd4J8SSwKPRN8MH+TqnCSMJvzhRvDkRS1iI=";
        };
      }
      {
        name = "elan-battery-fix";
        patch = pkgs.fetchpatch {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/hid/hid.git/patch/?id=bcc31692a1d1e21f0d06c5f727c03ee299d2264e";
          hash = "sha256-DLuyu2o7Hh0CmrA3Zx9VaxYtGdYlNZcWxTfjIPh4ilc=";
        };
      }
      {
        name = "keyboard-brightness-fix";
        patch = pkgs.fetchpatch {
          url = "https://marc.info/?l=linux-kernel&m=172085686420004&q=mbox";
          hash = "sha256-9hik4PZqDld1m9F7tILmYqc3YbayvqE6peuSFQmrAOw=";
        };
      }
      {
        name = "keyboard-fix";
        patch = ./keyboard-fix.patch;
      }
    ];
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Filesystems
    supportedFilesystems = [ "ntfs" ];

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    sensor.iio.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        vpl-gpu-rt
      ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;
  services.hardware.bolt.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
  systemd.tmpfiles.rules = [
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80" # 80% Battery Limit Default
  ];

#  # Second Screen Disable + KVMFR rule
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", RUN+="${pkgs.systemd}/bin/systemctl --no-block start zenbook-keyboard.service"
    ACTION=="remove", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", RUN+="${pkgs.systemd}/bin/systemctl --no-block start zenbook-keyboard.service"
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
  '';
  systemd.services.zenbook-keyboard = {
    description = "Sync displays with keyboard connect state";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 0.1"; # On disconnect, the script sometimes gets called before the device is removed
      ExecStart = "${pkgs.bash}/bin/bash /etc/zenbook/zenbook-keyboard.sh";
      TimeoutStartSec = "1s";
    };
    unitConfig = {
      StartLimitIntervalSec = 0.2;
      StartLimitBurst = 1;
    };
  };
  systemd.services.display-manager-startup = {
    description = "Sync display-manager with keyboard connect state";
    wantedBy = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1"; # Can probably be lower, but a second doesn't matter to me
      ExecStart = "${pkgs.bash}/bin/bash /etc/zenbook/zenbook-keyboard.sh";
      TimeoutStartSec = "2s";
    };
  };
  environment.etc."zenbook/zenbook-keyboard.sh" = {
    mode = "0555";
    text = ''
      #${pkgs.bash}/bin/bash
      export WAYLAND_DISPLAY=$(find /run/user/*/wayland-0)

      if [ -n "$WAYLAND_DISPLAY" ]; then
        if ${pkgs.usbutils}/bin/lsusb | grep -q "0b05:1b2c"; then
            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.enable output.eDP-2.disable
        else
            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.enable output.eDP-1.position.0,0 output.eDP-2.enable output.eDP-2.position.0,900
        fi
      fi
    '';
  };

  # Networking
  time.timeZone = "America/Louisville";
  #time.hardwareClockInLocalTime = true; # Windows is silly and I need it for work/school
  networking = {
    hostName = "BURGUNDY";
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      # Syncthing
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
      checkReversePath = false; # Wireguard
    };
  };

  # Video
  environment.variables.__RM_NO_VERSION_CHECK = "1";

  # VFIO
  environment.etc."looking-glass-client.ini".text = ''
    [app]
    shmFile=/dev/kvmfr0
  '';
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    namespaces = []
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kvmfr0"
    ]
  '';
  #systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 collin kvm -" ];
  virtualisation.spiceUSBRedirection.enable = true;

  # Disks
  boot.tmp.cleanOnBoot = true;

  # BTRFS Scrubbing
  services.btrfs.autoScrub = {
    fileSystems = [ "/home" ]; # Crosses subpartition bounds
    enable = true;
    interval = "weekly";
  };

  # BTRFS De-duplicating
  services.beesd.filesystems = {
    system = {
      spec = "/home";
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
    };
  };

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
        "/var/lib/libvirt" # Keep KVM junk
        "/var/lib/iwd" # I like using WiFi
        "/var/lib/bluetooth" # I like using my keyboard
        { directory = "/var/lib/syncthing"; user = "collin"; group = "collin"; }
        "/var/lib/NetworkManager" # I like using WiFi
        "/etc/NetworkManager/system-connections" # I like using WiFi
      ];
      files = [
        "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
        "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
        "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
      ];
   };
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}