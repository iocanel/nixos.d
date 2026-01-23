{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.display.hyprland = {
    enable = mkEnableOption "Enable Hyprland compositor";
  };

  config = mkIf config.custom.display.hyprland.enable {
    # Enable common Wayland configuration
    custom.display.wayland-common.enable = true;

    # Hyprland-specific packages
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      hyprland
      hyprpaper
      hyprlock
      hypridle
      hyprpicker
      hyprpanel  # Hyprland-specific bar
      hyprpwcenter  # Pipewire audio control
      hyprviz
      hyprlandPlugins.hy3
    ];

    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # XDG Portal configuration for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        hyprland = mkForce {
          default = "hyprland";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
    };

    # PAM configuration for hyprlock
    security.pam.services.hyprlock = {
      gnupg = {
        enable = true;
        noAutostart = false;
        storeOnly = false;
      };
    };
  };
}
