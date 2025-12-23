{ config, lib, pkgs, ... }:

{
  # Base work-mode target - foundational capability
  systemd.targets.work-mode = {
    description = "Work Mode - Base capability for work-related services";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  # VPN target - requires work-mode as a capability  
  systemd.targets.vpn = {
    description = "VPN Services - Requires work mode";
    wantedBy = [ "work-mode.target" ];
    requires = [ "work-mode.target" ];
    after = [ "work-mode.target" ];
  };

  # Convenience script for work mode management
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "work-mode" ''
      #!/bin/bash
      
      case "''${1:-status}" in
        "start"|"enable"|"on")
          echo "Starting work mode..."
          sudo systemctl start work-mode.target
          ;;
        "stop"|"disable"|"off") 
          echo "Stopping work mode..."
          sudo systemctl stop work-mode.target
          ;;
        "restart"|"reload")
          echo "Restarting work mode..."
          sudo systemctl restart work-mode.target
          ;;
        "status"|"s")
          systemctl status work-mode.target vpn.target --no-pager -n 0
          ;;
        "help"|"h"|"-h"|"--help")
          echo "Work Mode Management"
          echo "Usage: work-mode [start|stop|restart|status|help]"
          echo "Manages work-mode.target which cascades to dependent services"
          ;;
        *)
          echo "Unknown command: $1"
          exit 1
          ;;
      esac
    '')
  ];
}