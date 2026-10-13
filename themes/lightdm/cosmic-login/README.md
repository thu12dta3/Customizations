# Cosmic Login

A responsive Catppuccin Mocha greeter theme for Garuda Linux with LightDM WebKit2 Greeter. It uses the supplied Milky Way photograph, a Portuguese 24-hour clock and date, a login card, and LightDM's authentication API.

The account row stays fixed when LightDM exposes one user. If it exposes multiple users, the row expands into a picker with each profile image and display name. The session is fixed to `plasma`, matching the Plasma Wayland session used by this setup. The background fills the screen with `cover`; a subtle dark gradient supports the left-aligned login column. The clock group stays vertically centered.

The login submit control is the small arrow inside the password field. Enter submits as well. The theme handles LightDM prompts, authentication errors, session start, and available restart/shutdown actions. It does not store or transmit credentials outside LightDM. In an ordinary browser the controls are intentionally disabled and marked as a visual preview.

## Install

From the repository root, stage the theme and official Arch package:

```bash
cd themes/lightdm/cosmic-login
./scripts/stage.sh
```

Staging installs `lightdm-webkit2-greeter` from the official Arch `extra` repository if needed and copies theme files into `/usr/share/lightdm-webkit/themes/cosmic-login`. It does not select or restart the greeter.

Depois de conferir o tema, valide a configuração e ative o Cosmic Login:

```bash
bash scripts/enable.sh --check
sudo bash scripts/enable.sh --apply
```

The installer backs up `/etc/lightdm/lightdm.conf` and `/etc/lightdm/lightdm-webkit2-greeter.conf` in a dated directory under `/var/backups`, then selects `lightdm-webkit2-greeter` and `cosmic-login`. It does not restart LightDM or end the current session. LightDM does not support a service reload here, so the running process may keep its current greeter until LightDM starts again. To undo the change, use the backup path printed by the installer:

```bash
sudo bash scripts/rollback.sh /var/backups/cosmic-login-activation-AAAAmmdd-HHMMSS-PID
```

The theme calls LightDM's own authentication and session-start API; it does not change PAM, passwords, autologin, or the selected Plasma session (`plasma`, including Wayland).

## Background image

`cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg` is the original supplied photograph. It is included as a separate asset; the repository's GPL-3.0 license does not change the photograph's own licensing terms. No credit text is overlaid on the login screen.

For the KDE System Settings SDDM theme selector, see the native Qt Quick variant in [`../../sddm/cosmic-login/`](../../sddm/cosmic-login/). It is a separate greeter theme and does not change the active display manager.
