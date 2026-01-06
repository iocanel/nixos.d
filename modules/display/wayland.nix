{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.display.wayland = {
    enable = mkEnableOption "Enable Wayland/Sway configuration";
  };

  config = mkIf config.custom.display.wayland.enable {
    # Wayland/Sway configuration
    services = {
      greetd = {
        enable = true;
        vt = 7;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd ${pkgs.swayfx}/bin/sway";
            user = "greeter";
          };
        };
      };
      
      # Disable X11 services
      xserver.enable = false;
    };

    # Wayland-specific packages
    environment.systemPackages = with pkgs; [
      swayfx
      swaylock
      swayidle
      wl-clipboard
      mako
      wofi
      waybar
      grim
      slurp
      wf-recorder
    ];

    # XWayland support
    programs.xwayland = {
      enable = true;
    };

    # Environment variables for Wayland
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_DESKTOP = "sway";
    };
  };
}