# Notebook: Lenovo LOQ 15IRH8, Intel UHD + RTX 3050 Laptop. Everything only this machine needs; the rest in common.nix.
# hardware.nix = this machine's nixos-generate-config output, kept verbatim (regenerate, never hand-edit).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../common.nix
    ./hardware.nix
  ];

  networking.hostName = "loc-nixos";

  boot = {
    # i915 in the initrd loads before nvidia, every boot. Connector names (eDP-1, DP-1..4 Intel, DP-5 and HDMI-A-1
    # NVIDIA) come from one counter across GPUs in load order, so a race renamed the panel. Bonus: native-res LUKS
    # prompt.
    initrd.kernelModules = [ "i915" ];
    # DDR5 SPD temperature sensor: its resume fails (`spd5118 ... failed to resume async: error -6`) and the error
    # flashes on the console when the lid opens. Only a RAM temperature reading is lost.
    blacklistedKernelModules = [ "spd5118" ];
    # Resume from hibernation: the swapfile below lives on the root filesystem, at this physical offset. Recreating
    # the swapfile (size change) moves it: recompute, `sudo filefrag -v /var/lib/swapfile`, extent 0 physical_offset.
    resumeDevice = config.fileSystems."/".device;
    kernelParams = [ "resume_offset=124332032" ];
  };

  hardware = {
    # NVIDIA: open kernel module (Ampere), PRIME offload. Intel renders the desktop (sway/bin/start orders the GPUs),
    # the dGPU runs `prime-run <app>` and drives the outputs wired to it (HDMI-A-1, DP-5).
    nvidia = {
      open = true;
      # PreserveVideoMemoryAllocations + kernel suspend notifiers (open module >= 595 default), so no
      # nvidia-suspend/resume services as on Arch. External monitor may still need sway/panels/display/reinit after resume.
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
  };

  # Internal mic (Realtek ALC257): the stock ACP path merges "Internal Mic Boost" (+30 dB) into the source volume, so
  # 100% = +60 dB and the mic clips on room noise; apps with auto gain (Meet) push it to 100%. Boost pinned at 0 dB
  # (volume = zero): 100% = +30 dB, the Capture element alone. PipeWire reads /etc/alsa-card-profile before its own.
  environment.etc."alsa-card-profile/mixer/paths/analog-input-internal-mic.conf".source =
    pkgs.runCommand "analog-input-internal-mic.conf" { }
      ''
        sed '/^\[Element Internal Mic Boost\]/,/^$/ s/^volume = merge$/volume = zero/' \
          ${pkgs.pipewire}/share/alsa-card-profile/mixer/paths/analog-input-internal-mic.conf >$out
        # Fails the build if upstream renames the section: the override would silently do nothing.
        sed -n '/^\[Element Internal Mic Boost\]/,/^$/p' $out | grep -qx 'volume = zero'
      '';

  # Hibernation target: a swapfile on the LUKS root, so the RAM image is encrypted at rest. 16 GiB = RAM: hibernates
  # even with memory full. zram (priority 5) still takes everyday swap first; this one is priority -2.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    thermald.enable = true; # Intel CPU thermal management
    # Battery at 4%: hibernate, the session comes back. common.nix powers off (machines without a disk swap). 4%, not
    # UPower's 2%: the reading drifts near empty on an aging battery; writing the image takes about 0.1 Wh of ~59.
    # Critical warning at 7% keeps a few minutes between the red notification and the hibernation.
    upower = {
      criticalPowerAction = lib.mkForce "Hibernate";
      percentageAction = 4;
      percentageCritical = 7;
    };
    # Lid: suspend, then hibernate (systemd.sleep below). Lid closed with an external monitor: ignored (logind's docked
    # default).
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  };

  # suspend-then-hibernate: on battery, hibernate after 2 h suspended; on AC, stay suspended. This battery has an ACPI
  # trip point (_BTP, BAT1/alarm), so without HibernateDelaySec systemd 260 skips its discharge estimate and hibernates
  # only if the firmware tags the wake as its battery alarm (DMI wake-up type "APM Timer"). This firmware leaves it at
  # "Power Switch" after a resume from deep sleep (checked 2026-11-18), so that path never hibernates: the timer is the
  # only one that does.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
    HibernateOnACPower = false;
  };
}
