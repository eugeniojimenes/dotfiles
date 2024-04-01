#!/bin/bash
# This will be executed whenever WSL starts.

# Execute the task we created before.
# /mnt/c/Windows/system32/schtasks.exe /run /tn "auto-mount-wsl"

/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -File C:\\Users\\Nila\\mount_drive.ps1

# Since mounting will take some time, if you need to do something with the mounted drives later,
# you will need to write some logic to wait for it to be ready.

# Fix the "Missing X server or $DISPLAY" for GUI apps
rm -rf /tmp/.X11-unix
ln -s /mnt/wslg/.X11-unix /tmp/
