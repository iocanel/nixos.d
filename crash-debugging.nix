# Temporary debugging configuration for system freeze issue
# Remove this entire file once the freeze problem is resolved
{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    # Debugging and diagnostic options
    "nmi_watchdog=1"             # Enable NMI watchdog to detect hard lockups
    "thunderbolt.dyndbg=+p"      # Enable Thunderbolt debug logging (verbose)
    # "pcie_aspm=off"            # REMOVED: This breaks USB devices via Thunderbolt
  ];
}