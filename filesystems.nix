# Filesystem configuration
{ config, lib, pkgs, ... }:

{
  # Encrypted devices - crypthome will be handled by systemd unit
  environment.etc."crypttab".text = ''
  '';
  
  # Ensure cryptsetup is available
  systemd.services.systemd-cryptsetup = {
    path = [ pkgs.cryptsetup ];
  };
  
  # Service to unlock crypthome when key becomes available
  systemd.services.crypthome-unlock = {
    description = "Unlock crypthome when key is available";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ cryptsetup ];
    script = ''
      if [ -f /root/home.key ] && [ -e /dev/disk/by-label/HOME ]; then
        if ! [ -e /dev/mapper/crypthome ]; then
          cryptsetup luksOpen /dev/disk/by-label/HOME crypthome --key-file /root/home.key
        fi
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
  fileSystems."/" =
  { 
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
  };

  fileSystems."/home" =
  { 
      device = "/dev/mapper/crypthome";
      fsType = "ext4";
      options = [ "nofail" "defaults" ];
  };

  fileSystems."/boot" =
  { 
      device = "/dev/disk/by-uuid/BA0E-5F22";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
  };
  
  # fileSystems."/mnt/usb" =
  # { 
  #     device = "/dev/sda1";
  #     fsType = "vfat";
  #     options = [ "nofail" "user" "rw" "uid=1000" "gid=100" "umask=0002" ];
  # };


  fileSystems."/mnt/media" = 
  {
    device = "192.168.1.250:/volume2/media";
    fsType = "nfs";
    options = [ "nofail" "bg" ];
  };

  fileSystems."/mnt/downloads" = 
  {
    device = "192.168.1.250:/volume2/downloads";
    fsType = "nfs";
    options = [ "nofail" "bg" ];
  };

  fileSystems."/mnt/bjj" = 
  {
    device = "192.168.1.250:/volume2/bjj";
    fsType = "nfs";
    options = [ "nofail" "bg" ];
  };

  swapDevices = [ ];
}