# Filesystem configuration
{ config, lib, pkgs, ... }:

{
  fileSystems."/" =
  { 
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
  };

  fileSystems."/home" =
  { 
      device = "/dev/disk/by-uuid/4882f657-3753-4e28-bd2e-25d259cdff4f";
      fsType = "ext4";
  };

  fileSystems."/boot" =
  { 
      device = "/dev/disk/by-uuid/BA0E-5F22";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
  };
  
  fileSystems."/mnt/usb" =
  { 
      device = "/dev/sda1";
      fsType = "vfat";
      options = [ "nofail" "user" "rw" "uid=1000" "gid=100" "umask=0002" ];
  };

  fileSystems."/mnt/bjj" = 
  {
    device = "192.168.1.250:/volume2/bjj";
    fsType = "nfs";
    options = [ "nofail" "bg" ];
  };

  swapDevices = [ ];
}