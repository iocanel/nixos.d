{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.display.sway = {
    enable = mkEnableOption "Enable Sway compositor";
  };

  config = mkIf config.custom.display.sway.enable {
    # Enable common Wayland configuration
    custom.display.wayland-common.enable = true;

    # Sway-specific packages
    environment.systemPackages = with pkgs; [
      swayfx
      swaybg
      swayidle
      swaylock-effects
    ];

    # Enable Sway
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
    };

    # XDG Portal configuration for Sway
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        sway = mkForce {
          default = "wlr";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    };

    # PAM configuration for swaylock
    security.pam.services.swaylock = {
      gnupg = {
        enable = true;
        noAutostart = false;
        storeOnly = false;
      };
    };
  };
}
