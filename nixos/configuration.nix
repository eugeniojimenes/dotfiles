# NixOS system for the notebook (Lenovo LOQ 15IRH8: Intel UHD + RTX 3050 Laptop). Not a stow module.
# /etc/nixos/configuration.nix imports it next to the generated hardware-configuration.nix, which stays there:
#   { imports = [ ./hardware-configuration.nix /home/callmarx/dotfiles/nixos/configuration.nix ]; }
# Channels, no flakes, no home-manager: dotfiles stay on stow, system packages live here.
# Apply: sudo nixos-rebuild switch. Update: sudo nixos-rebuild switch --upgrade.
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  # Every rebuild = new boot entry (rollback). 10 keeps the 1G ESP from filling up.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "loc-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  # The initrd LUKS prompt uses this keymap too, only with earlySetup. Sway sets its own layout per keyboard.
  console.keyMap = "br-abnt2";
  console.earlySetup = true;

  users.users.callmarx = {
    isNormalUser = true;
    # docker = root-equivalent, kept as on Arch. i2c = ddcutil (external monitor brightness). video = swayosd.
    extraGroups = [ "wheel" "networkmanager" "docker" "i2c" "video" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  # Old generations hold their whole closure on disk. Weekly sweep, 30 days of rollback kept.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # NVIDIA: open kernel module (Ampere), PRIME offload. Intel renders the desktop (sway/start orders the GPUs),
  # the dGPU runs `prime-run <app>` and drives the outputs wired to it (HDMI-A-1, DP-1).
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    # nvidia-suspend/resume/hibernate + PreserveVideoMemoryAllocations, as on Arch. External monitor still needs
    # sway/display/reinit after resume.
    powerManagement.enable = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      # Arch's name (nvidia-prime), so Steam launch options carry over.
      offload.offloadCmdMainProgram = "prime-run";
      # lspci 0000:00:02.0 and 0000:01:00.0 as PCI:bus@domain:device:function, decimal.
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  # Everything sway/.config/sway runs. Portals (wlr for screen sharing, gtk for the rest), polkit and the swaylock
  # PAM file (Quickshell lock authenticates through it) come with this module.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaybg swayidle swaylock waybar fuzzel mako quickshell swayosd wiremix alacritty
      grim slurp wl-clipboard libnotify playerctl brightnessctl ddcutil jq
      gtk3 # gtk-launch, menu app entries
    ];
  };
  # LUKS passphrase already gates the boot: straight into Sway. Exit Sway = tuigreet.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "callmarx";
        command = "/home/callmarx/.config/sway/start";
      };
      default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd /home/callmarx/.config/sway/start";
    };
  };
  # Electron and Chromium wrappers in nixpkgs go native Wayland with this, no XWayland blur.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # GTK dark + icons, what gsettings held on Arch. Defaults only, `gsettings set` still overrides.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
        icon-theme = "Yaru-purple";
      };
    }
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  hardware.i2c.enable = true;
  zramSwap.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  # Brave/Slack secrets. Autologin never unlocks it: empty password at the first prompt, the disk is LUKS anyway.
  services.gnome.gnome-keyring.enable = true;
  services.gnome.sushi.enable = true;
  services.gvfs.enable = true; # Nautilus: trash, phones, network shares
  services.locate.enable = true; # plocate
  virtualisation.docker.enable = true;

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.localsend.enable = true; # opens 53317
  programs.gnome-disks.enable = true;
  # bash/.config/bash/init sources /usr/share/fzf, absent here; this loads the same key bindings from /etc/bashrc.
  programs.fzf.keybindings = true;
  # Prebuilt binaries mise and Mason download (Node, Python, Ruby, rustup, LSPs) expect /lib64/ld-linux-x86-64.so.2.
  programs.nix-ld.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    # Apps
    brave google-chrome slack postman dbeaver-bin spotify obs-studio mpv obsidian libreoffice typora evince
    xournalpp imv pinta nautilus transmission_4-gtk yaru-theme
    # CLI. gh, glab, node, python, ruby, rust, go, uv and claude come from mise.
    git tmux neovim stow age mise curl wget unzip unrar zstd file tree btop htop bat eza fd ripgrep fzf zoxide
    starship lazygit lazydocker jq gum tlrc yt-dlp imagemagick fastfetch typst pandoc yq-go xmlstarlet
    # Dev: gcc for treesitter parsers and Rust linking, clang-tools for clangd.
    gcc gnumake cmake clang-tools tree-sitter git-filter-repo terraform openfortivpn
    # Hardware
    pciutils usbutils stress-ng memtester dmidecode
  ];

  # Release of the first install. Never bump on upgrades: pins state formats (databases, paths), not versions.
  system.stateVersion = "26.05";
}
