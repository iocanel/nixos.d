{ config, pkgs, lib, ... }:

with lib;

{
  options.cybersecurity = {
    enable = mkEnableOption "cybersecurity tools and packages";
  };

  config = mkIf config.cybersecurity.enable {
    environment.systemPackages = with pkgs; [
      # Network Security & Analysis
      nmap
      smap # Drop-in replacement for nmap powered by shodan.io
      masscan
      rustscan
      wireshark
      tcpdump
      binwalk
      netcat
      netcat-gnu
      socat
      proxychains
      
      # Vulnerability Assessment
      nuclei
      
      # WiFi Security Testing
      aircrack-ng
      kismet
      
      # Web Security
      (symlinkJoin {
        name = "burpsuite-wrapped";
        paths = [ burpsuite ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/burpsuite \
            --set _JAVA_AWT_WM_NONREPARENTING 1 \
            --set GDK_BACKEND x11
        '';
      })
      sqlmap
      nikto
      
      # Password Security
      john
      hashcat
      thc-hydra
      medusa
      ncrack
      cewl
      # Wordlists & Security Testing Lists
      wordlists
      seclists

      
      # OSINT (Open Source Intelligence)
      theharvester
      sherlock
      recon-ng
      amass
      waybackurls
      gau
      uncover
           
      # Exploitation & Post-Exploitation
      # Metasploit Framework (with gem extensions fixed via overlay)
      metasploit
      # dependencies
      ruby
      gem
      bundler
      rubyPackages.racc
      rubyPackages.rbs
      #

      armitage
      weevely
      python312Packages.impacket
      
      # Container Security Testing
      (pkgs.stdenv.mkDerivation rec {
        pname = "deepce";
        version = "2024-12-18";
        
        src = pkgs.fetchurl {
          url = "https://github.com/stealthcopter/deepce/raw/main/deepce.sh";
          sha256 = "1q449pj2nfrbw78p4hwvv3bj69243z2lxjji53xip8lki87ra978";
        };
        
        dontUnpack = true;
        dontBuild = true;
        
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/deepce
          chmod +x $out/bin/deepce
        '';
        
        meta = with pkgs.lib; {
          description = "Docker Enumeration, Escalation of Privileges and Container Escapes";
          homepage = "https://github.com/stealthcopter/deepce";
          license = licenses.mit;
          platforms = platforms.linux;
          maintainers = [ ];
        };
      })
      
      # Credential Extraction & Windows Security Testing
      mimikatz # Windows credential extraction and WDigest vulnerability demonstration
            
      # Utilities
      exif
      curl
      wget
      git
      neovim
      tmux
      screen
      tree
      htop
    ];

    # Enable additional kernel modules for security testing
    boot.kernelModules = [
      "netfilter_log"    # For network monitoring
      "nf_conntrack"     # Connection tracking
      "usbmon"           # USB monitoring for security analysis
      "rfcomm"           # Bluetooth security testing
    ];

    # Configure group memberships for security tools
    users.groups.cybersec = {};

    # Enable wireshark for non-root users
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    # Configure udev rules for USB security analysis
    services.udev.extraRules = ''
      # Allow members of cybersec group to access USB monitoring
      SUBSYSTEM=="usbmon", GROUP="cybersec", MODE="0640"
      
      # Enable raw socket access for security tools
      KERNEL=="tun", GROUP="cybersec", MODE="0660"
    '';

    # Allow monitor mode for wireless testing
    networking.wireless.userControlled.enable = mkDefault true;
    
    # Configure sysctl settings for security analysis
    boot.kernel.sysctl = {
      # Allow unprivileged access to network namespaces for some security tools
      "user.max_user_namespaces" = mkDefault 28633;
      
      # Enable BPF for advanced network analysis
      "kernel.unprivileged_bpf_disabled" = mkDefault 0;  # Allow for security analysis
    };

    # Create convenient symlinks for wordlists and seclists in /share
    systemd.tmpfiles.rules = [
      "L+ /share/wordlists - - - - ${pkgs.wordlists}/share/wordlists"
      "L+ /share/seclists - - - - ${pkgs.seclists}/share/wordlists/seclists"
    ];
  };
}
