{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.display.xorg = {
    enable = mkEnableOption "Enable X.org/i3 configuration";
  };

  config = mkIf config.custom.display.xorg.enable {
    # X.org/i3 configuration
    services = {
      # Disable Wayland services
      greetd.enable = false;
      
      xserver = {
        enable = true;
        
        displayManager = {
          lightdm = {
            enable = true;
            greeters.gtk.enable = true;
          };
        };
        
        windowManager = {
          i3 = {
            enable = true;
            extraPackages = with pkgs; [
              dmenu
              rofi
              i3lock
              i3blocks
              i3status
              feh
              picom
              arandr
              autorandr
            ];
          };
        };
        
        desktopManager = {
          xterm.enable = false;
        };
        
        xkb = {
          variant = "";
          options = "grp:alt_shift_toggle";
          layout = "us,gr";
        };
      };
    };

    # X11-specific packages
    environment.systemPackages = with pkgs; [
      xclip
      xorg.xrandr
      xorg.xdpyinfo
      xorg.xwininfo
      autorandr
      arandr
      picom
      feh
      nitrogen
      dunst
      polybar
    ];

    # Enable monitor hotplug for X11
    hardware.monitor-hotplug.enable = true;

    # Environment variables for X11
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "xcb";
      GDK_BACKEND = "x11";
    };
  };
}