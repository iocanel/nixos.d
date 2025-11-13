#
# My NixOS configuration
#

#
# Requirements:
#
# 1. home manager
#    $ nix-channel --add https://github.com/nix-community/home-manager/archive/release-24-05.tar.gz home-manager
#    $ nix-channel --update
# 

#
# After performing changes
# $ sudo nixos-rebuild switch
# $ sudo nixos-rebuild --install-bootloader boot

# Cleaning up
# $ nix-env --delete-generations 3d


#
# To GC old generations:
# $ nix-env --delete-generations 7d
#

{ config, pkgs, lib, fetchFromGithub, ... }:
  let
    #
    # Define the paths to your custom packages
    #
    mvnd = pkgs.callPackage /etc/nixos/packages/mvnd/default.nix { };
    quarkus-cli = pkgs.callPackage /etc/nixos/packages/quarkus-cli/default.nix { };
    quarkus-cli-3-14-3 = pkgs.callPackage /etc/nixos/packages/quarkus-cli/3-14-3.nix { };
    quarkus-cli-3-14-4 = pkgs.callPackage /etc/nixos/packages/quarkus-cli/3-14-4.nix { };
    idpbuilder = pkgs.callPackage /etc/nixos/packages/idpbuilder/0.8.1.nix { };
    jmc = pkgs.callPackage /etc/nixos/packages/jmc/default.nix { };
    kagent = pkgs.callPackage /etc/nixos/packages/kagent/default.nix { };
    cursor-ide = pkgs.callPackage /etc/nixos/packages/cursor-ide/default.nix { };
    udev-scripts = pkgs.callPackage /etc/nixos/packages/udev-scripts/default.nix { };
    
    #
    # Allow cherry-picking from the unstable
    #
    unstable = import (builtins.fetchTarball { url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz"; }) {
      config = { allowUnfree = true; };
    };
    
  #  home-manager = import (builtins.fetchTarball { url = "https://github.com/nix-community/home-manager/archive/master.tar.gz"; }) {
  #    inherit (unstable) pkgs;
  #    config = { allowUnfree = true; };
  #  };
  in
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/superdrive.nix
      ./private/index.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.grub.enable = false;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.initrd.luks.devices = {
    "cryptroot" = {      
      device = "/dev/disk/by-uuid/2205cc86-d099-4cc7-8899-143f4ea6a222";
      preLVM = true;
    };
  };

  # Use kernel 6.17
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    hostName = "canelio";
    hosts = {
      "my-app.local" = [ "127.0.0.1" ];
    };
  };
  
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable networkd
  networking.useNetworkd = true;

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8";
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";
    LC_TELEPHONE = "el_GR.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    blueman = {
      enable = true;
    };
    dbus = {
      enable = true;
      packages = [ pkgs.gamemode ];
    };
    
    displayManager = {
    };
    
    greetd = {
      enable = true;
      vt = 7;
      settings = {
        # Greeter UI that prompts for your username/password, then launches a session
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd ${pkgs.swayfx}/bin/sway";
          user = "greeter";
        };
      };
    };

    # Configure keymap in X11
    xserver = {
      enable = false;
      desktopManager = {
        xterm.enable = true;
      };
      windowManager = {
        i3 = {
          enable = false;
          extraPackages = with pkgs; [
            dmenu
	          rofi
	          i3lock
	          i3blocks
          ];
        };
      };
      displayManager = {
    	  gdm = {
          enable = false;
        };
      };
      desktopManager = {
        gnome = {
          enable = false;
        };
      };
      xkb = {
        variant = "";
        options = "grp:alt_shift_toggle";
        layout = "us,gr";
      };
    };
    
    pulseaudio = {
      enable = false;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-switch-on-port-available
        load-module module-detect
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
      '';
      
      # Disabled extraConfig
      #  load-module module-udev-detect
      #  load-module module-alsa-source device=hw:0,0
      #  load-module module-combine-sink
    };

    resolved = {
      enable = false;
    };
    
    udisks2 = {
      enable = true;
    };
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    clipmenu.enable = false;
    openssh.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    ollama = {
      enable = true;
      acceleration = "cuda";  # Use CUDA acceleration for your NVIDIA GPU
      environmentVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
      };
      openFirewall = false;  # Keep it local for security
    };
    
  };
    
  # Enable FUSE for user mounts
  programs.fuse.userAllowOther = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users = {
    defaultUserShell = pkgs.fish;
    groups = {
      iocanel = {
      };
      www-data = {
        gid = 33;
      };
      ydotool = {
      };
    };
    users = {
      www-data = {
        uid = 33;
        isSystemUser = true;
        group = "www-data";
      };
      iocanel = {
        isNormalUser = true;
        description = "Ioannis Canellos";
        extraGroups = [ "root" "wheel" "users" "iocanel" "audio" "video" "adbusers" "docker" "www-data" "networkmanager" "disk" "transmission" "deluge" "input" "fuse" "kvm" "libvirt" "podman" ];
        linger = true;
      };
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          # single string, not a list
          default = "wlr";
          # explicitly use GTK for file chooser dialogs
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
        };
      };
    };
  };
 
  home-manager = {
    users.iocanel = /home/iocanel/.config/home-manager/home.nix;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
     "dotnet-sdk-6.0.428"
  ];

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Overlays
   nixpkgs.overlays = [
    (import /etc/nixos/overlays/custom-java-overlay.nix)
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     stdenv # nixos build essentials
     home-manager
     bash
     fish
     direnv
     pass
     pinentry-curses
     pinentry-qt
     stow
     linux-firmware     # Additional firmware support
     # Android
     android-tools
     android-udev-rules
     #
     # AI
     #
     ollama
     #
     # Clipboard Management
     #
     clipmenu
     clipnotify
     xclip
     xsel
     #
     # Containers
     #
     docker
     docker-buildx
     docker-machine-kvm2
     docker-compose
     podman
     podman-compose
     #
     # Drivers
     #
     brlaser
     #
     # Editors
     #
     webkitgtk_4_1
     emacs
     neovim
     #
     # Development
     #
     git
     gnumake
     # C
     gcc
     glibc
     cmake
     libtool
     # Java
     temurin-bin-21
     temurin-bin-23
     maven
     gradle
     jbang
     quarkus-cli
     spring-boot-cli
     jmc
     # Javascript
     nodejs
     yarn-berry
     typescript-language-server
     # Go
     go
     # Python
     python311
     poetry
     
     # Rust
     rustup
     rustc
     rustfmt
     cargo
     rust-analyzer
     # Suggested by:  https://github.com/NixOS/nixpkgs/blob/0109d6587a587170469cb11afc18a3afe71859a3/doc/languages-frameworks/rust.section.md#using-the-rust-nightlies-overlay
     binutils
     pkg-config
     
     # SQL
     sqlite
     # Stores     
     redis
     # Tools
     unstable.code-cursor

     # Utils
     #Devices
     sg3_utils
     lm_sensors
     #
     # Graphics
     #
     gnuplot
     #
     # Kubernetes
     #
     kubectl
     istioctl
     k9s
     kubernetes-helm
     kind
     minikube
     idpbuilder
     kagent

     #
     # Office
     #
     libreoffice
     texliveFull
     obsidian
     #
     # Terminal
     #
     alacritty
     rxvt-unicode
     xterm
     # Terminal UI
     fzf
     ripgrep
     bat
     eza
     dust
     htop
     # Media Center     
     deluge
     # Tools
     unzip
     unrar
     p7zip
     rsync
     udiskie
     # System tools
     lsof
     pciutils
     usbutils
     pam_gnupg
     libnotify
     
     # Overrides
     dotnet-sdk
     
     #Virtualization
     qemu
     qemu_kvm

     # Wayland/Sway desktop bits
     swayfx swaybg swayidle swaylock-effects waybar wofi wofi-pass
     wl-clipboard clipman
     grim slurp swappy wf-recorder
     mako kanshi brightnessctl
  ];

  fonts.packages = with pkgs; [
     nerd-fonts.hack
     nerd-fonts.fira-code
     nerd-fonts.inconsolata
     nerd-fonts.jetbrains-mono
     nerd-fonts.ubuntu-mono
     nerd-fonts.ubuntu-sans
     font-awesome
     hack-font
     fira-code
     powerline-fonts
     material-icons
     material-design-icons
     source-code-pro
     inconsolata
     dejavu_fonts
     fg-virgil

  ];
  programs = {
    nix-ld = {
      enable = true;
    };

    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };


    fish = {
      enable = true;
    };

    java = {
      enable = true;
    };
    
    xwayland = {
      enable = true;
    };
    
    sway = {
      enable = true;
      package = pkgs.swayfx;
    };
    
    ydotool = {
      enable = true;
      group = "input";
    };
  };

  #
  # Hardware
  #
  hardware = {
    superdrive = {
      enable = true;
    };
  };

  #
  # Printing
  #

  #
  # Virtualisation
  #
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
      daemon = {
        settings = {
          ipv6 = false;
          # Use the modern "runtimes" configuration format (not "runtime")
          # The old "runtime" section is deprecated and conflicts with newer Docker versions
          # Enable CDI (Container Device Interface) for modern GPU support
          features.cdi = true;
        };
      };
    };
    
    # Podman as alternative container runtime with better GPU support
    podman = {
      enable = true;
      # Enable Docker compatibility (allows using 'docker' command with Podman)
      dockerCompat = false; # Keep false to avoid conflicts with Docker
      # Default network settings
      defaultNetwork.settings.dns_enabled = true;
    };
    
    oci-containers = {
      backend =  "docker";
    };
  };

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [
        22   #SSH
        80   # HTTP
        443  # HTTPS

        8008 # WEB APP
        8443 # SECURE WEB APP
        
        8920 # EMBY SERVER
        8989 # SONARR
        7878 # RADARR
        6767 # BAZARR
        9117 # JACKET
        6881 # DELUGE
        6891 # DELUGE
      ];
    };
  };

  # Allow non-privileged users to use dmesg
  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
  # Swap configuration for memory pressure relief
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192; # 8GB swap file
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";

  # Don’t rebuild an immutable man-db cache on every nixos-rebuild
  documentation.man.generateCaches = false;

  systemd = {
    services.systemd-networkd-wait-online.enable = lib.mkForce false;
    mounts = [
      {
        what = "192.168.1.250:/volume2/downloads";
        where = "/mnt/downloads";
        type = "nfs";
        options = "defaults,timeo=10,retrans=3,hard,noauto,x-systemd.automount,x-systemd.device-timeout=10s";
      }
      {
        what = "192.168.1.250:/volume2/media";
        where = "/mnt/media";
        type = "nfs";
        options = "defaults,timeo=10,retrans=3,hard,noauto,x-systemd.automount,x-systemd.device-timeout=10s";
      }
    ];
    services = {
      docker = {
        path = [ pkgs.glibc.getent ];
      };
      fc-cache-update = {
        description = "Update font cache";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.fontconfig}/bin/fc-cache -fv'";
          RemainAfterExit = true;
        };
      };
    };
    
    paths = {
    };

    network = {
      enable = true;
      # netdevs = {
      #   br1 = {
      #      netdevConfig = {
      #       Kind = "bridge";
      #      Name = "br1";
      #    };
      #   };
      # };
      networks = {
        eth1 = {
          matchConfig.Name = "enp196s0f0";
          DHCP = "ipv4";
        };

       # br1 = {
       #   matchConfig.Name = "br1";
       #   DHCP = "ipv4";
       # };
       # br1-bind = {
       #   matchConfig.Name = "en*";
       #   networkConfig.Bridge="br1";
       # };
      };
    };
  };

  security = {
    pam = {
      services = {
        login = {
          gnupg = {
            enable = true;
            noAutostart = true;
            storeOnly = true;
          };          
        };
        swaylock = {
        };
      };
    };
  };
  
  environment.variables = {
    DOCKER_BUILDKIT = 1;  # Globally enable BuildKit
  };
  
   environment.sessionVariables = {
     XDG_CURRENT_DESKTOP = "sway";
     XDG_SESSION_DESKTOP = "sway";
     MOZ_ENABLE_WAYLAND = "1";
     QT_QPA_PLATFORM = "wayland";
     QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
     SDL_VIDEODRIVER = "wayland";
     NIXOS_OZONE_WL = "1";  # Chromium/Electron
   };


  environment.etc."udev/scripts/deauth-usb.sh" = {
    text = ''
    #!/bin/bash
    echo 0 > "/sys/$1/authorized"
    '';
    mode = "0755";
  };


  services.udev = {
    packages = [ udev-scripts ];
      
    extraRules = ''
      # Rule to deauthorize USB device
      #ACTION=="add", SUBSYSTEM=="usb", ENV{DEVPATH}!="", RUN+="/lib/udev/scripts/deauth-usb.sh %p"
      
      # Rule to ignore /dev/video5 as it is not working properly
      #KERNEL=="video5", SUBSYSTEM=="video4linux", OPTIONS+="ignore_device"
      
      # Lenovo Thunderbolt 3 dock support
      # Automatically authorize Lenovo Thunderbolt devices
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0x17aa", ATTR{authorized}=="0", ATTR{authorized}="1"
      
      # Specific rules for common Lenovo Thunderbolt 3 dock models
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0x17aa", ATTR{device}=="0x1012", ATTR{authorized}="1"
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0x17aa", ATTR{device}=="0x1010", ATTR{authorized}="1"
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0x17aa", ATTR{device}=="0x402b", ATTR{authorized}="1"
      
      # Enable USB devices connected through Thunderbolt dock
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="17aa", ATTR{authorized}="1"
    '';
  };


  #
  # Package activation
  #

  # Create a symlink for /bin/bash
  environment.etc."bash".source = "${pkgs.bash}/bin/bash";
  # Alternatively, use system activation script to create the symlink
  system.activationScripts.bash = {
    text = ''
      mkdir -p /bin
      ln -sf ${pkgs.bash}/bin/bash /bin/bash
    '';
  };
}
