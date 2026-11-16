# NixOS config shared by every machine. Not a stow module. Each machine's /etc/nixos/configuration.nix imports its
# own hosts/<hostname>.nix, which imports this file; hardware-configuration.nix stays generated in /etc/nixos:
#   { imports = [ ./hardware-configuration.nix /home/callmarx/dotfiles/nixos/hosts/<hostname>.nix ]; }
# Channels, no flakes, no home-manager: dotfiles stay on stow, system packages live here.
# Apply: sudo nixos-rebuild switch. Update: sudo nixos-rebuild switch --upgrade.
# Formatted with nixfmt (official style, RFC 166); one block per top-level option.
{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # Every rebuild = new boot entry (rollback). 10 keeps the 1G ESP from filling up.
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking.networkmanager.enable = true;

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
    bluetooth.enable = true;
    i2c.enable = true;
  };

  security.rtkit.enable = true;
  zramSwap.enable = true;
  virtualisation.docker.enable = true;

  services = {
    # LUKS passphrase already gates the boot: straight into Sway. Exit Sway = tuigreet.
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          user = "callmarx";
          command = "/home/callmarx/.config/sway/bin/start";
        };
        default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd /home/callmarx/.config/sway/bin/start";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      # x11-bell segfaults pipewire whenever Xwayland goes away (session-env exports DISPLAY). No X bell needed.
      extraConfig.pipewire."99-no-x11-bell"."context.properties"."module.x11.bell" = false;
    };
    power-profiles-daemon.enable = true;
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
    # icu on top of the default library set: .NET binaries (Mason's marksman) abort without libicu.
    nix-ld = {
      enable = true;
      libraries = [ pkgs.icu ];
    };
  };

  # File dialogs (Brave, Slack...) open in Nautilus instead of the GTK3 chooser of portal-gtk. Nautilus implements the
  # FileChooser portal itself but ships no .portal file; the one below declares it. Desktop-keyed file replaces the one
  # the sway package ships, so its routes are repeated here.
  xdg.portal.config.sway = {
    default = "gtk";
    "org.freedesktop.impl.portal.FileChooser" = "nautilus";
    "org.freedesktop.impl.portal.ScreenCast" = "wlr";
    "org.freedesktop.impl.portal.Screenshot" = "wlr";
    "org.freedesktop.impl.portal.Inhibit" = "none";
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
    (runCommandLocal "nautilus-portal" { } ''
      mkdir -p $out/share/xdg-desktop-portal/portals
      printf '[portal]\nDBusName=org.gnome.Nautilus\nInterfaces=org.freedesktop.impl.portal.FileChooser\n' \
        >$out/share/xdg-desktop-portal/portals/nautilus.portal
    '')
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
    # LSP servers for the Claude Code LSP plugins (ruby-lsp comes from the mise Ruby postinstall)
    gopls
    lua-language-server
    pyright
    gnupg # mise verifies Node release signatures
    libxkbcommon # xkbcli: dotfiles-doctor cedilla check
    xdg-user-dirs # ~/Pictures and friends (sway autostart), xdg-user-dir for screenshots
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
