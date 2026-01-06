{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.display-manager;
in
{
  imports = [
    ./display/wayland.nix
    ./display/xorg.nix
  ];

  options.custom.display-manager = {
    enable = mkEnableOption "Enable custom display manager configuration";
    
    backend = mkOption {
      type = types.enum [ "wayland" "xorg" ];
      default = "wayland";
      description = "Display backend to use (wayland/sway or xorg/i3)";
    };
  };

  config = mkIf cfg.enable {
    # Enable the selected backend
    custom.display.wayland.enable = cfg.backend == "wayland";
    custom.display.xorg.enable = cfg.backend == "xorg";
  };
}