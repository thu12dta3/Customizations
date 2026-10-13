# Troubleshooting — LightDM WebKit2

## Black screen with a visible pointer

If the greeter is entirely black but the pointer moves or seems to interact with invisible controls, the page may have loaded while WebKitGTK failed to composite its pixels. On NVIDIA systems, accelerated compositing or the DMABUF renderer may be involved. This is different from a rejected password.

First confirm which greeter and theme LightDM has selected:

```bash
systemctl status display-manager --no-pager
lightdm --show-config
grep -nE '^\s*webkit_theme\s*=' /etc/lightdm/lightdm-webkit2-greeter.conf
```

Check whether the greeter opened a session and inspect its service messages:

```bash
sudo journalctl -b -u lightdm --no-pager
```

A `pam_unix(lightdm:session): session opened` line confirms that authentication opened a session; it does not prove that the greeter image rendered correctly. Do not type your password blindly. If you are stuck at a black screen, use `Ctrl`+`Alt`+`F3` to open a text terminal, sign in, and follow the rollback steps below.

## NVIDIA rendering compatibility

WebKitGTK provides `WEBKIT_DISABLE_DMABUF_RENDERER=1` to disable its DMABUF renderer and use another rendering path. The workaround also disables accelerated compositing with `WEBKIT_DISABLE_COMPOSITING_MODE=1`. Results depend on the GPU, driver and WebKitGTK combination; verify the screen visually on your machine.

In the case that prompted this guide, `WEBKIT_DISABLE_COMPOSITING_MODE=1` alone **did not** fix the black screen. The DMABUF path is an additional attempt; consider it fixed only after confirming that the greeter is visibly drawn after LightDM starts again.

From a clone of this repository, with Cosmic Login already enabled:

```bash
cd themes/lightdm/cosmic-login
sudo bash scripts/apply-nvidia-render-workaround.sh
```

The script:

- backs up the current configuration and wrapper under `/var/backups/cosmic-login-webkit-nvidia-*`;
- installs a wrapper that passes both environment variables to the WebKit greeter;
- configures `greeter-wrapper` in LightDM and validates it with LightDM's own parser;
- keeps `lightdm-webkit2-greeter` and `cosmic-login` selected;
- does not restart the service or end your session automatically.

Save your work and restart LightDM to test the next greeter. **This ends the current graphical session.**

```bash
sudo systemctl restart lightdm
```

## Rollback

Use the backup path printed by the script. This restores the state immediately before the workaround and keeps the already-active Cosmic configuration:

```bash
sudo bash /var/backups/cosmic-login-webkit-nvidia-DATE-TIME-PID/rollback.sh \
  /var/backups/cosmic-login-webkit-nvidia-DATE-TIME-PID
sudo systemctl restart lightdm
```

To also undo the original Cosmic activation, use the `cosmic-login-activation-*` backup created by `scripts/enable.sh`, as described in the [installation guide](README.md).

## Additional diagnostics

Record the active GPU and driver:

```bash
lspci -k | grep -A4 -Ei 'VGA|3D|Display'
```

Inspect LightDM logs locally; avoid posting complete system logs publicly because unrelated application logs can contain private data. If this workaround does not fix rendering, restore it from the backup and investigate the Xorg/NVIDIA driver and WebKit errors before attempting another restart.

This adjustment does not change PAM, passwords, autologin, the Plasma session, SDDM, GRUB or partitions. WebKitGTK describes the DMABUF variable as a way to switch the renderer path: [WebKitGTK 2.41.1](https://planet.webkitgtk.org/2023/05/18/webkitgtk-2-41-1/). An upstream report also documents WebKitGTK compositing failures on NVIDIA: [WebKit bug 180739](https://bugs.webkit.org/show_bug.cgi?id=180739).
