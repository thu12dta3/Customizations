# Cosmic Lock Screen — X11 / XFCE, MATE, Cinnamon, LXQt and window managers

**Experimental — not yet verified by a real authentication cycle on this backend.**

Requirements: i3lock-color (the plain i3lock build is unsupported). Python 3 is needed only to stage/restore files, not to handle passwords.

This is an opt-in alternative native X11 locker, not a theme for xfce4-screensaver, mate-screensaver or cinnamon-screensaver. It must not be used under XWayland to lock a Wayland desktop. CLI flags were checked against upstream i3lock-color; live X11/PAM testing remains pending. Native indicator UI differs from Plasma's text field.

## Install the standalone download

Extract this backend's ZIP and open a terminal inside its extracted folder. Run without sudo:

```bash
bash scripts/install.sh --dry-run
bash scripts/install.sh --allow-experimental
```

The native locker must already be installed. The installer creates isolated user-owned theme files, an included font, and a launcher at `~/.local/bin/cosmic-x11-lock`. It saves previous files for rollback. Existing PAM files, native default configuration, lock shortcuts and idle services are left untouched.

## Test before integration

Run the launcher only in the matching desktop/session:

```bash
"$HOME/.local/bin/cosmic-x11-lock"
```

Confirm correct-password unlock, incorrect-password rejection and coverage of every monitor before assigning it to suspend or autolock. These native authentication checks were **not** performed in this repository's automated tests.

After testing a full lock/unlock cycle, manually configure your desktop's preferred lock command or shortcut. Do not configure two competing idle lockers. Keep a copy of the previous command to restore it. XFCE/MATE/Cinnamon/LXQt integration is a separate opt-in step.

## Restore

```bash
python3 scripts/rollback.py --backend x11
```

The rollback restores only the files this installer manages. Restore any manual lock/idle binding changes using your saved configuration.

Code: GPL-3.0-or-later. Font: OFL-1.1, see `OFL.txt`. The included photograph retains its original licensing terms.
