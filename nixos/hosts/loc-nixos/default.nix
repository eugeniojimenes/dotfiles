# Notebook: Lenovo LOQ 15IRH8, Intel UHD + RTX 3050 Laptop. Everything only this machine needs; the rest in common.nix.
# hardware.nix = this machine's nixos-generate-config output, kept verbatim (regenerate, never hand-edit).
{ ... }:

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
  };

  hardware = {
    # NVIDIA: open kernel module (Ampere), PRIME offload. Intel renders the desktop (sway/bin/start orders the GPUs),
    # the dGPU runs `prime-run <app>` and drives the outputs wired to it (HDMI-A-1, DP-5).
    nvidia = {
      open = true;
      # PreserveVideoMemoryAllocations + kernel suspend notifiers (open module >= 595 default), so no
      # nvidia-suspend/resume services as on Arch. External monitor may still need sway/display/reinit after resume.
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

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    thermald.enable = true; # Intel CPU thermal management
  };
}
