# Cosmic Lock Screen — Hyprlock / Hyprland

**Experimental — not yet verified by a real authentication cycle on this backend.**

Requirements: hyprlock 0.9.x. Python 3 is needed only to stage/restore files, not to handle passwords.

Install hyprlock with your distribution. This configuration uses native Hyprlock widgets and the default native PAM module; fingerprint/custom auth settings can be reviewed in the staged config. Compositor and PAM testing has not been completed here.

## Install the standalone download

Extract this backend's ZIP and open a terminal inside its extracted folder. Run without sudo:

```bash
bash scripts/install.sh --dry-run
bash scripts/install.sh --allow-experimental
```

The native locker must already be installed. The installer creates isolated user-owned theme files, an included font, and a launcher at `~/.local/bin/cosmic-hyprlock-lock`. It saves previous files for rollback. Existing PAM files, native default configuration, lock shortcuts and idle services are left untouched.

## Test before integration

Run the launcher only in the matching desktop/session:

```bash
"$HOME/.local/bin/cosmic-hyprlock-lock"
```

Confirm correct-password unlock, incorrect-password rejection and coverage of every monitor before assigning it to suspend or autolock. These native authentication checks were **not** performed in this repository's automated tests.

On Hyprland, after manual testing, use the launcher in your chosen lock binding / hypridle configuration. Back up those files first. No binding is changed by this installer.

## Restore

```bash
python3 scripts/rollback.py --backend hyprlock
```

The rollback restores only the files this installer manages. Restore any manual lock/idle binding changes using your saved configuration.

Code: GPL-3.0-or-later. Font: OFL-1.1, see `OFL.txt`. The included photograph retains its original licensing terms.

Configuration keys follow the [official Hyprlock documentation](https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/). The native Hyprlang parser smoke test checks syntax/basic property types, not custom gradient/layout callbacks or authentication.
