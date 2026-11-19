# Hibernation

Files: `nixos/hosts/loc-nixos/default.nix` (swapfile, resume device and offset, lid action, sleep settings, battery action), `sway/.config/sway/panels/menu/menu.mjs` (System › Suspend and Hibernate).

## Purpose

The notebook can keep a session across a power-off: the RAM image goes to an encrypted swapfile on the LUKS root and comes back after the passphrase at boot. Closing the lid suspends as before, and on battery the machine hibernates after 2 hours suspended, so a forgotten notebook never loses its session. At 4% battery the notebook hibernates instead of powering off, after the critical warning at 7%.

## Acceptance criteria

1. With hibernation set up (the kernel's resume device is set), System › Suspend in the menu runs `systemctl suspend-then-hibernate` and System › Hibernate runs `systemctl hibernate`. Test: `tests/unit/sway/.config/sway/panels/menu/menu.bats: "hibernation set up: Suspend hibernates later and Hibernate is listed; without it, plain Suspend"`
2. Without it (the desktop, no swapfile), Suspend runs a plain `systemctl suspend` and there is no Hibernate entry. Test: `tests/unit/sway/.config/sway/panels/menu/menu.bats: "hibernation set up: Suspend hibernates later and Hibernate is listed; without it, plain Suspend"`
3. After the reboot the kernel knows where to resume from: `/sys/power/resume` shows the root device and `/sys/power/resume_offset` the swapfile's offset. Test: manual
4. System › Hibernate locks the session, powers the notebook off, and after the LUKS passphrase the session returns as it was: windows, terminals, the external monitor, and the NVIDIA card back to `suspended` when idle. Test: manual
5. Closing the lid on battery suspends; on AC it stays suspended. The lock screen is up on resume either way. Test: manual
6. On battery, after 2 hours suspended with the lid closed, the notebook hibernates (`HibernateDelaySec`), whether or not the firmware wakes it at the battery's trip point. On AC the timer is reset and it stays suspended (`HibernateOnACPower = false`). Test: manual
