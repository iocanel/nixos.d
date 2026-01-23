{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.display.wayland-common = {
    enable = mkEnableOption "Enable common Wayland configuration";
  };

  config = mkIf config.custom.display.wayland-common.enable {
    # Common Wayland packages (used by both Sway and Hyprland)
    environment.systemPackages = with pkgs; [
      waybar
      wofi
      wofi-pass
      wl-clipboard
      clipman
      grim
      slurp
      swappy
      wf-recorder
      mako
      kanshi
      brightnessctl
    ];

    # Ensure wayland-sessions directory is linked into system profile
    environment.pathsToLink = [ "/share/wayland-sessions" ];

    # XWayland support
    programs.xwayland.enable = true;

    # Common Wayland environment variables
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}
