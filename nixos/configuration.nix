# NixOS system for the notebook (Lenovo LOQ 15IRH8: Intel UHD + RTX 3050 Laptop). Not a stow module.
# /etc/nixos/configuration.nix imports it next to the generated hardware-configuration.nix, which stays there:
#   { imports = [ ./hardware-configuration.nix /home/callmarx/dotfiles/nixos/configuration.nix ]; }
# Channels, no flakes, no home-manager: dotfiles stay on stow, system packages live here.
# Apply: sudo nixos-rebuild switch. Update: sudo nixos-rebuild switch --upgrade.
# Formatted with nixfmt (official style, RFC 166); one block per top-level option.
{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      # Every rebuild = new boot entry (rollback). 10 keeps the 1G ESP from filling up.
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "loc-nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  # The initrd LUKS prompt uses this keymap too, only with earlySetup. Sway sets its own layout per keyboard.
  console = {
    keyMap = "br-abnt2";
    earlySetup = true;
  };

  users.users.callmarx = {
    isNormalUser = true;
    # docker = root-equivalent, kept as on Arch. i2c = ddcutil (external monitor brightness). video = swayosd.
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "i2c"
      "video"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    # flakes off for the system (channels), on for `nix shell` / `nix search`.
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Old generations hold their whole closure on disk. Weekly sweep, 30 days of rollback kept.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Hard-links identical store files on a timer, not during every build (auto-optimise-store slows builds).
    optimise.automatic = true;
  };

  hardware = {
    graphics.enable = true;
    # NVIDIA: open kernel module (Ampere), PRIME offload. Intel renders the desktop (sway/start orders the GPUs),
    # the dGPU runs `prime-run <app>` and drives the outputs wired to it (HDMI-A-1, DP-1).
    nvidia = {
      open = true;
      # nvidia-suspend/resume/hibernate + PreserveVideoMemoryAllocations, as on Arch. External monitor still needs
      # sway/display/reinit after resume.
      powerManagement.enable = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
          # Arch's name (nvidia-prime), so Steam launch options carry over.
          offloadCmdMainProgram = "prime-run";
        };
        # lspci 0000:00:02.0 and 0000:01:00.0 as PCI:bus@domain:device:function, decimal.
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };
    bluetooth.enable = true;
    i2c.enable = true;
  };

  security.rtkit.enable = true;
  zramSwap.enable = true;
  virtualisation.docker.enable = true;

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    # LUKS passphrase already gates the boot: straight into Sway. Exit Sway = tuigreet.
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          user = "callmarx";
          command = "/home/callmarx/.config/sway/start";
        };
        default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd /home/callmarx/.config/sway/start";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    fwupd.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    gnome = {
      # Brave/Slack secrets. Autologin never unlocks it: empty password at the first prompt, the disk is LUKS anyway.
      gnome-keyring.enable = true;
      sushi.enable = true;
    };
    gvfs.enable = true; # Nautilus: trash, phones, network shares
    locate.enable = true; # plocate
  };

  programs = {
    # Everything sway/.config/sway runs. Portals (wlr for screen sharing, gtk for the rest), polkit and the swaylock
    # PAM file (Quickshell lock authenticates through it) come with this module.
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaybg
        swayidle
        swaylock
        waybar
        fuzzel
        mako
        quickshell
        swayosd
        wiremix
        alacritty
        grim
        slurp
        wl-clipboard
        libnotify
        playerctl
        brightnessctl
        ddcutil
        jq
        gtk3 # gtk-launch, menu app entries
      ];
    };
    # GTK dark + icons. Defaults only, `gsettings set` still overrides.
    dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          icon-theme = "Yaru-purple";
        };
      }
    ];
    firefox.enable = true;
    steam.enable = true;
    localsend.enable = true; # opens 53317
    gnome-disks.enable = true;
    # fzf key bindings (Ctrl-R, Ctrl-T, Alt-C) from /etc/bashrc; bash/.config/bash/init relies on it.
    fzf.keybindings = true;
    # Prebuilt binaries mise and Mason download (Node, Python, Ruby, rustup, LSPs) expect /lib64/ld-linux-x86-64.so.2.
    nix-ld.enable = true;
  };

  # Electron and Chromium wrappers in nixpkgs go native Wayland with this, no XWayland blur.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    # Apps
    brave
    google-chrome
    slack
    postman
    dbeaver-bin
    spotify
    obs-studio
    mpv
    obsidian
    libreoffice
    typora
    evince
    xournalpp
    imv
    pinta
    nautilus
    transmission_4-gtk
    yaru-theme
    # CLI. gh, glab, node, python, ruby, rust, go, uv and claude come from mise.
    git
    tmux
    neovim
    stow
    age
    mise
    curl
    wget
    unzip
    unrar
    zstd
    file
    tree
    btop
    htop
    bat
    eza
    fd
    ripgrep
    fzf
    zoxide
    starship
    lazygit
    lazydocker
    jq
    gum
    tlrc
    yt-dlp
    imagemagick
    fastfetch
    typst
    pandoc
    yq-go
    xmlstarlet
    # Dev: gcc for treesitter parsers and Rust linking, clang-tools for clangd.
    gcc
    gnumake
    cmake
    clang-tools
    tree-sitter
    git-filter-repo
    terraform
    openfortivpn
    # Hardware
    pciutils
    usbutils
    stress-ng
    memtester
    dmidecode
  ];

  # Release of the first install. Never bump on upgrades: pins state formats (databases, paths), not versions.
  system.stateVersion = "26.05";
}
