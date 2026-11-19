# NixOS config shared by every machine. Not a stow module. flake.nix (repo root) builds one system per
# hosts/<hostname>/, which imports this file plus that machine's hardware.nix.
# Flake, pinned nixpkgs (flake.lock), no home-manager: dotfiles stay on stow, system packages live here.
# Apply: sudo nixos-rebuild switch --flake ~/dotfiles. Update: nix flake update, then the same switch.
# A flake only sees files git tracks: `git add` a new file before rebuilding.
# Formatted with nixfmt (official style, RFC 166); one block per top-level option.
{ pkgs, nixpkgs-unstable, ... }:

let
  # Login name picked in the installer: the account and its home exist already. Changing it here makes a new user, it
  # does not rename this one.
  user = "callmarx";
  start = "/home/${user}/.config/sway/bin/start";
in
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # Every rebuild = new boot entry (rollback). 10 keeps the 1G ESP from filling up.
        configurationLimit = 10;
        # No kernel command-line edit at the menu: `init=/bin/sh` = root shell without a password. Broken boot = pick
        # an older entry instead.
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      # Menu shown 1 s instead of 5: enough to tap an arrow key for an older generation, any key stops the countdown.
      timeout = 1;
    };
  };

  networking.networkmanager = {
    enable = true;
    # Real MAC never sent on connect: one fixed MAC per network name. Home router keeps seeing the same one; the MAC
    # alone does not link visits across places. Hostname and DHCPv6 DUID still go out the same everywhere (NM
    # defaults kept, docs/nixos.md "Wi-Fi MAC address"). Scan MAC is already random (NetworkManager default).
    wifi.macAddress = "stable-ssid";
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  # The initrd LUKS prompt uses this keymap too, only with earlySetup. Sway sets its own layout per keyboard.
  console = {
    keyMap = "br-abnt2";
    earlySetup = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    # docker = root-equivalent, kept as on Arch. i2c = ddcutil (external monitor brightness). Backlight = brightnessctl
    # through logind, no video group.
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "i2c"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    # System = flake (flake.nix). nix-shell -p and <nixpkgs> follow the same pinned nixpkgs (nixosSystem sets it).
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
    bluetooth = {
      enable = true;
      # No pairing agent runs (the Sway panel has none). Without one BlueZ keeps the adapter non-bondable, so a pairing
      # is never stored (Bonded: no) and a headset drops it on the first disconnect.
      settings.General.AlwaysPairable = true;
    };
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
          inherit user;
          command = start;
        };
        default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${start}";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      # x11-bell segfaults pipewire whenever Xwayland goes away (session-env exports DISPLAY). No X bell needed.
      extraConfig.pipewire."99-no-x11-bell"."context.properties"."module.x11.bell" = false;
      wireplumber.extraConfig = {
        # KEF LSX II LT (USB speaker): when the host stops its stream after idle, the firmware stops answering control
        # requests (`usb_set_interface -110`) and only a replug brings it back. Never suspended; matches nothing else.
        "51-kef-lsx-no-suspend"."monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output.usb-KEF_LSX_II_LT.*"; } ];
            actions.update-props."session.suspend-timeout-seconds" = 0;
          }
        ];
        # Bluetooth audio: WirePlumber connects no profile on its own by default (bluez5.auto-connect = []), so a
        # speaker or receiver that connects only part of its profiles stays silent until reconnected. A2DP both ways.
        # The headset mic (HFP) is untouched: WirePlumber switches to it when an app opens the microphone.
        "51-bluez-a2dp-autoconnect"."monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props."bluez5.auto-connect" = [
              "a2dp_sink"
              "a2dp_source"
            ];
          }
        ];
      };
    };
    power-profiles-daemon.enable = true;
    # Battery levels for poweralertd (notifications, sway autostart) and the action at 2%. Default HybridSleep needs a
    # disk swap: power off here, a host with a swapfile and resume set hibernates instead (loc-nixos).
    upower = {
      enable = true;
      criticalPowerAction = "PowerOff";
    };
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
        quickshell
        wiremix
        alacritty
        grim
        slurp
        satty # bin/screenshot: Edit button of the notification
        hyprpicker # bin/colorpick
        # Screen recording: bin/record, and README media (harness skill update-media: wf-recorder, then ffmpeg to GIF).
        wf-recorder
        ffmpeg-headless
        wl-clipboard
        libnotify
        # Password dialog for polkit (gnome-disks, Nautilus admin, pkexec), started by Sway from
        # /run/current-system/sw/libexec (pathsToLink below).
        polkit_gnome
        poweralertd
        gammastep # bin/nightlight
        cliphist # bin/clipboard
        # bin/ocr. English and Portuguese only: the default build carries every language.
        (tesseract.override {
          enableLanguages = [
            "eng"
            "por"
          ];
        })
        # bin/emoji: wtype types the pick, unicode-emoji is the list (pathsToLink below).
        wtype
        unicode-emoji
        playerctl
        brightnessctl
        ddcutil
        jq
        gtk3 # gtk-launch, menu app entries
      ];
    };
    # GTK dark + icons. Defaults only, `gsettings set` still overrides. color-scheme = GTK4/libadwaita, Chromium; GTK3
    # ignores it and needs a theme by name: adw-gtk3 (systemPackages) looks like libadwaita. Plain GTK3 ships no
    # "Adwaita-dark": an unknown name falls back to light Adwaita.
    dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          cursor-theme = "Adwaita";
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment = {
    sessionVariables = {
      # Electron and Chromium wrappers in nixpkgs go native Wayland with this, no XWayland blur.
      NIXOS_OZONE_WL = "1";
      # NixOS default = nano (mkDefault). Session-wide, not only bash/.config/bash/env: the tmux server started from
      # Sway and anything it runs (Claude Code Ctrl+G) never source an interactive bashrc.
      EDITOR = "nvim";
    };

    # tmux plugins at a fixed path, run by tmux.conf. Pinned by flake.lock and updated with the system: TPM pulled each
    # plugin repo's HEAD on every bin/update, with no release-age wait.
    etc = {
      "tmux/plugins/sensible".source = "${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible";
      "tmux/plugins/resurrect".source = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect";

      # Input method for Chromium and Electron (Brave, Slack): they compose dead keys with a built-in table and ignore
      # ~/.XCompose, so ' + c gave ć on us/intl. Through the Wayland text-input protocol (Brave's wrapper passes
      # --enable-wayland-ime) fcitx5 composes with libxkbcommon, which reads ~/.XCompose. Started by sway
      # (90-autostart). Plain fcitx5, not i18n.inputMethod: that one adds fcitx5-configtool and its KDE Frameworks
      # (~470 MiB) through a path nothing here can override. Keyboard only, each keyboard keeps its Sway layout.
      "xdg/fcitx5/profile".text = ''
        [Groups/0]
        Name=Default
        Default Layout=us-intl
        DefaultIM=keyboard-us-intl

        [Groups/0/Items/0]
        Name=keyboard-us-intl

        [GroupOrder]
        0=Default
      '';
      # No popup, tray icon, clipboard or emoji picker, and only the Wayland frontend: X11 apps compose with Xlib, which
      # reads ~/.XCompose itself. No hotkeys (Ctrl+Space, a lone Left Shift and Super+Space switched it). An empty
      # section is an empty key list. Left loaded: wayland, waylandim, keyboard, dbus; ~14 MB of its own, 8 of them the
      # keyboard addon's list of every xkb layout.
      "xdg/fcitx5/config".text = ''
        [Behavior]
        ShowInputMethodInformation=False

        [Behavior/DisabledAddons]
        0=classicui
        1=clipboard
        2=emoji
        3=kimpanel
        4=notificationitem
        5=notifications
        6=quickphrase
        7=unicode
        8=xcb
        9=xim
        10=ibusfrontend
        11=fcitx4frontend
        12=imselector
        13=virtualkeyboard
        14=dbusfrontend

        [Hotkey/ActivateKeys]

        [Hotkey/AltTriggerKeys]

        [Hotkey/DeactivateKeys]

        [Hotkey/EnumerateGroupBackwardKeys]

        [Hotkey/EnumerateGroupForwardKeys]

        [Hotkey/TogglePreedit]

        [Hotkey/TriggerKeys]
      '';
    };

    # Not linked into /run/current-system/sw by default: libexec/ = polkit_gnome's agent, share/unicode = the emoji
    # list for bin/emoji.
    pathsToLink = [
      "/libexec"
      "/share/unicode"
    ];

    systemPackages = with pkgs; [
      # Apps
      brave
      google-chrome
      slack
      postman
      dbeaver-bin
      spotify
      obs-studio
      # uosc interface from nixpkgs: pinned by flake.lock, ziggy built from source, fonts through the wrapper. Never
      # uosc's own installer or its Update menu: a copy in ~/.config/mpv/scripts would load a second uosc on top.
      # mpris: mpv on MPRIS, so the bar, the media keys and the sound panel see and drive it like any player.
      (mpv.override {
        scripts = [
          mpvScripts.uosc
          mpvScripts.mpris
        ];
      })
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
      adw-gtk3 # GTK3 theme, see dconf above
      # Cursors (and the icon fallback GTK4 apps expect). Already in the closure as a GTK dependency, this only exposes
      # it; NixOS sets no default cursor theme, so without it Sway draws the old X11 core cursors.
      adwaita-icon-theme
      # CLI. gh, glab, node, python, ruby, rust, go, uv and claude come from mise.
      git
      tmux
      neovim
      stow
      age
      gitleaks # ~/.private snapshot scans for secrets before archiving
      # Unstable recipe on stable packages, flake.nix says why. Tests off: built locally, no binary cache hit.
      # rust-bindgen: openssl-sys in this recipe fails without the bindgen CLI.
      ((pkgs.callPackage "${nixpkgs-unstable}/pkgs/by-name/mi/mise/package.nix" { }).overrideAttrs (old: {
        doCheck = false;
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.rust-bindgen ];
      }))
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
      fcitx5 # input method, see xdg/fcitx5 above
      # Hardware
      pciutils
      usbutils
      stress-ng
      memtester
      dmidecode
    ];
  };

  # Screen-share picker (sway/.config/sway/bin/share-picker): the NixOS module starts the portal with --config=<these
  # settings>, so ~/.config/xdg-desktop-portal-wlr is never read. Empty settings = slurp picked, picker and dnd never ran.
  xdg.portal.wlr.settings.screencast = {
    chooser_type = "dmenu";
    chooser_cmd = "/home/${user}/.config/sway/bin/share-picker";
    # A share starting while no other is live (the portal runs it only then), also Brave's real share after its
    # preview, which skips the picker: hide notifications unless the last pick was a window.
    exec_before = "/home/${user}/.config/sway/bin/share-picker started";
    # Once every share has ended: notifications back.
    exec_after = "/home/${user}/.config/sway/bin/dnd share-off";
  };
  # The unit's PATH holds coreutils, grim and slurp only: the picker needs quickshell, jq and swaymsg, dnd needs pkill.
  systemd.user.services.xdg-desktop-portal-wlr.path = [ "/run/current-system/sw" ];

  # Release of the first install. Never bump on upgrades: pins state formats (databases, paths), not versions.
  system.stateVersion = "26.05";
}
