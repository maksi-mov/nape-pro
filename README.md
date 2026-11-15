# Nape Pro issue

Using wire and USB mode on Keychron Nape Pro (NP-2) have problem in firmware 1.0.0 - 1.3.3:

Buttons with Next DPI, Scroll or other non-ordinary actions sends a vendor notification. When Launcher isn’t reading it, firmware eventually blocks on that notification, stopping the shared USB mouse and keyboard report.

| State | DPI / Scroll |
|---|---|
| Wired, Launcher disconnected | Freezes reporting |
| Wired, Launcher connected | Works |
| Disconnect from Launcher | Problem returns |
| Start in radio mode, then attach cable while staying in radio mode | Works—even after removing receiver |
| Connect Launcher again and then disconnect | Working, then Freezes |

# Workaround
Immitate hidraw read destinned for Launcher.
```sh
# as example:
#  hidraw0 used for mouse/keyboard reports from trackball, which blocked when you clicked "Next DPI"/"Scroll" buttons.
#  hidraw1 used for configuration via Launcher, which we need to read, so hidraw0 unblocked for read.
sudo cat /sys/class/hidraw/hidraw1 > /dev/null
# after that reports on hidraw0 will be available for read
```

# NixOS module
We start systemd service by udev rule, which triggered when Nape Pro device connected.

- copy module
```sh
cp nape.nix /etc/nixos/
```

- import module:

```
 # /etc/nixos/configuration.nix
 imports =
 [
   ./nape.nix
 ];
```

- rebuild system:
```sh
nixos-rebuild switch
```