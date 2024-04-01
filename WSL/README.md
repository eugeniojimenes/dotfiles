## Arch linux for WSL
 - Source: <https://github.com/yuk7/ArchWSL>
 - Wiki: <https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/>

## Auto mount partition at startup
Add the content of [mount_drive.ps1](./mount_drive.ps1) on your Windows user folder. In the following example is
`C:\\Users\\Nila\\mount_drive.ps1`.

Then in your /etc/wsl.conf:

```conf
[boot]
systemd=true
command="bash /boot.sh"
```

The /boot.sh content should be:
```sh
#!/bin/bash
/bin/bash /wsl-boot.sh > /wsl-boot.log 2>&1
```

And use [wsl-boot.sh](./wsl-boot.sh) as your guide to run the PowerShell script to mount the desire partition.

About a self elevating privilege PowerShell script: <https://learn.microsoft.com/pt-br/archive/blogs/virtual_pc_guy/a-self-elevating-powershell-script>

## Fix the "Missing X server or $DISPLAY" for GUI apps
As you can see at the end of [wsl-boot.sh](./wsl-boot.sh) we have:

```sh
# Fix the "Missing X server or $DISPLAY" for GUI apps
rm -rf /tmp/.X11-unix
ln -s /mnt/wslg/.X11-unix /tmp/
```

This approach was suggested by <https://github.com/microsoft/wslg/issues/1156#issuecomment-1841237823>

## Clipboard on Windows WSL
To be able clipboard on Windows WSL you need [win32yank](https://github.com/equalsraf/win32yank). Download the
.exe file and do the following:

```sh
sudo cp ~/Downloads/win32yank.exe /usr/local/bin
sudo chmod +x /usr/local/bin/win32yank.exe
```

## Video Reference
I based my WSL setup by this video: <https://youtu.be/sjrW74Hx5Po?si=c3bVljbZZQFw6PWw>

