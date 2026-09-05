# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,inputs,osu, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  boot.kernelPackages = pkgs.linuxPackages_zen;   
  
  # Enable networking
 
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Set your time zone.
  time.timeZone = "America/Mazatlan";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8 * 1024;
  } ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."teslapiss" = {
    isNormalUser = true;
    description = "Rodolfo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # NVIDIA drivers
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  #auto clean
  nix.gc = {
   automatic = true;
   dates = "weekly";
   options = "--delete-older-than 30d";
  };

  nix.optimise = {
   automatic = true;
   dates = [ "weekly" ];
  };
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos#nixos";
    dates = "04:00";
    allowReboot = true;
  };
   
  networking.wireless.iwd.enable = true;

  #limit generations
  boot.loader.systemd-boot.configurationLimit = 5;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.xserver.enable = true;
 
  
   programs.steam.enable = true; 
  

    programs.fish = {
     enable = true;
     interactiveShellInit = ''
      set fish_greeting # Disable greeting
     '';
   };
   services.flatpak.enable = true;
   services.power-profiles-daemon.enable = true;
   services.upower.enable = true;
   
  
programs.nix-ld = {
  enable = true;

  libraries = with pkgs; [
    pipewire
    alsa-lib
    openssl
  ];
};

  programs.niri.enable = true;
  services.greetd = {
   enable = true;
    settings = {
      default_session = {
       command = "${config.programs.niri.package}/bin/niri-session";
       user = "teslapiss";
      };
    };
  };
  programs.dconf.enable = true;
  xdg.icons.enable = true; 
  

    # $ nix search wget
  environment.systemPackages = with pkgs; [
  neovim
  kitty
  git
  matugen
  quickshell
  thunar
  pavucontrol
  awww
  firefox
  vscodium
  spotify
  prismlauncher
  xwayland-satellite
  libnotify
  cava
  brightnessctl
  wineWow64Packages.stable
  winetricks
  librewolf
  obs-studio
  inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default
  wl-clipboard
  mako
  jq
  kdePackages.breeze-icons
  papirus-icon-theme
  nwg-look
  osu  
  ];
   
   services.udev.extraRules =
  let
    toggleHdmi = pkgs.writeShellScript "toggle-hdmi" ''
      export XDG_RUNTIME_DIR="/run/user/1000"
      SOCKET=$(${pkgs.findutils}/bin/find "$XDG_RUNTIME_DIR" -name "niri.wayland-*.sock" 2>/dev/null | head -n1)
      export NIRI_SOCKET="$SOCKET"

      LAPTOP="eDP-1"
      HDMI="HDMI-A-1"

      OUTPUTS=$(${pkgs.niri}/bin/niri msg --json outputs)

      if echo "$OUTPUTS" | ${pkgs.jq}/bin/jq -e "has(\"$HDMI\")" > /dev/null 2>&1; then
        ${pkgs.niri}/bin/niri msg output "$LAPTOP" off
        ${pkgs.niri}/bin/niri msg output "$HDMI" on
      else
        ${pkgs.niri}/bin/niri msg output "$HDMI" off
        ${pkgs.niri}/bin/niri msg output "$LAPTOP" on
      fi
    '';
  in ''
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${toggleHdmi}"
  '';
    
  fonts.packages = with pkgs; [
      (google-fonts.override {
    fonts = [
      "Roboto"
      "DynaPuff"
      "Syne"

    ];
  })
  material-symbols
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
