# Dell Precision 16 Pro Max specific hardware configuration
{ config, lib, pkgs, ... }:

{
  # CPU-specific optimizations for AMD Ryzen AI 7 PRO 350 (Zen 5)
  boot.kernelParams = [
    # Enable AMD P-State for better power management
    "amd_pstate=active"
    # Enable enhanced security features
    "spec_store_bypass_disable=on"
    "l1tf=full,force"
    
    # Prevent random freezes
    "processor.max_cstate=1"
    
    # USB optimizations for docks/hubs
    "usbcore.autosuspend=-1"     # Disable USB autosuspend globally
    "usb-storage.delay_use=0"    # Reduce USB storage detection delay
    "usbhid.mousepoll=1"         # Increase mouse polling rate
    "usbcore.old_scheme_first=1" # Try old USB enumeration first
    # "amd_iommu=on"               # Disabled - using NVIDIA only
    "iommu=pt"                   # Pass-through mode for IOMMU
    "pci=realloc"                # Fix PCI resource allocation failures on this hardware
  ];

  boot.kernelModules = [ 
    "kvm-amd"           # AMD virtualization
    "usbhid"            # USB HID support
    "hid_generic"       # Generic HID support
    "hid_multitouch"    # Multitouch HID support
    "usb_storage"       # USB storage support
    "snd_pci_ps"        # Sound support for AMD/Intel HDA
    "uinput"            # Input device module for Dell laptop features
    "thunderbolt"       # Thunderbolt module for proper device management
  ];

  # List packages for Dell-specific hardware support
  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    lm_sensors        # Temperature monitoring
    usbutils          # USB debugging tools  
    pciutils          # PCI debugging tools
    bolt              # Thunderbolt device management CLI
  ];

  hardware = {
    # NVIDIA GPU configuration for hybrid setup
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      
      # Disable AMD GPU - use NVIDIA only
      # prime disabled for pure NVIDIA mode
      
      # Power management for laptops (finegrained disabled - requires PRIME offload)
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      
      # Use open source kernel modules (recommended for newer cards)
      open = true;  # Required for RTX 1000 Pro
    };

    nvidia-container-toolkit = {
      enable = true;
    };
    
    # AMD Ryzen AI 7 PRO 350 (Zen 5) optimizations
    cpu.amd = {
      updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    
    # Enable advanced CPU features
    enableRedistributableFirmware = true;
    
    # AMD GPU completely disabled
    # amdgpu.amdvlk.enable = false;
    
    # Graphics support (replaces opengl in NixOS 24.05+)
    graphics = {
      enable = true;
      enable32Bit = true;  # For 32-bit applications
    };
    
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    
    # Power management optimizations for laptop
    acpilight.enable = true;  # Better backlight control 
  };
  
  # Enable NVIDIA video drivers for X11
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # USB and input device services
  services = {
    hardware = {
      bolt = {
        enable = true;  # Thunderbolt device management
      };
    };
    # Enable udev for proper device detection
    udev = {
      extraRules = ''
        # USB device rules for better dock/hub support
        # CRITICAL REQUIREMENT: Laptop must work with Thunderbolt USB hub disconnected/reconnected 
        # or connected after boot. Never break this functionality.
        SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
        SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        
        # Input device rules
        SUBSYSTEM=="input", GROUP="input", MODE="0664"
        SUBSYSTEM=="hidraw", GROUP="input", MODE="0664"
        
        # USB HID device rules
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="input"
        
        # Mouse and keyboard specific rules
        SUBSYSTEM=="input", KERNEL=="mouse*", GROUP="input", MODE="0664"
        SUBSYSTEM=="input", KERNEL=="event*", GROUP="input", MODE="0664"
      '';
      packages = [ pkgs.usbutils ];
    };
    
    # Enable upower for better power management with docks
    upower = {
      enable = true;
    };
  };

  # Docker configuration for NVIDIA GPU support
  virtualisation.docker.daemon.settings = {
    # Use the modern "runtimes" configuration format (not "runtime")
    # The old "runtime" section is deprecated and conflicts with newer Docker versions
    # Create a custom wrapper to fix PATH issues with nvidia-container-cli
    runtimes = {
      nvidia = {
        path = "${pkgs.writeShellScript "nvidia-container-runtime-wrapper" ''
          export PATH="${pkgs.nvidia-container-toolkit}/bin:${pkgs.libnvidia-container}/bin:$PATH"
          exec ${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime "$@"
        ''}";
      };
    };
  };
  
  # Power management settings
  powerManagement = {
    # Disable USB autosuspend to prevent disconnects
    powerUpCommands = ''
      echo -1 > /sys/module/usbcore/parameters/autosuspend
      for usb in /sys/bus/usb/devices/*/power/autosuspend; do
        [ -w "$usb" ] && echo -1 > "$usb"
      done
      for usb in /sys/bus/usb/devices/*/power/control; do
        [ -w "$usb" ] && echo on > "$usb"
      done
    '';
  };
}