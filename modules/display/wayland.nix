{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.display.wayland;
in
{
  imports = [
    ./wayland-common.nix
    ./sway.nix
    ./hyprland.nix
  ];

  options.custom.display.wayland = {
    enable = mkEnableOption "Enable Wayland configuration";
  };

  config = mkIf cfg.enable {
    # Enable both Sway and Hyprland
    custom.display.sway.enable = true;
    custom.display.hyprland.enable = true;

    # Configure greetd for session selection
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # tuigreet will discover sessions from /run/current-system/sw/share/wayland-sessions
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --sessions /run/current-system/sw/share/wayland-sessions";
          user = "greeter";
        };
      };
    };

    # PAM configuration for greetd
    security.pam.services.greetd = {
      gnupg = {
        enable = true;
        noAutostart = false;
        storeOnly = false;
      };
    };
  };
}
