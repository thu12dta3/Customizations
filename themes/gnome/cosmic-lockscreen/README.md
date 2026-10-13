# Cosmic Lock Screen — GNOME Shell extension

**Experimental — not yet verified by a real authentication cycle on this backend.**

Requirements: GNOME Shell 46–51 (experimental API guards). Python 3 is needed only to stage/restore files, not to handle passwords.

This extension only decorates native GNOME actors. It does not replace verifier/unlock methods, read password fields, or alter GDM/PAM. The supported metadata versions are experimental targets, not verified compatibility. JavaScript syntax and mocked decoration/cleanup lifecycle passed; real GNOME Shell/PAM testing remains pending. If the native layout is unsupported, it leaves the native lock screen in control.

## Install the standalone download

Extract this backend's ZIP and open a terminal inside its extracted folder. Run without sudo:

```bash
bash scripts/install.sh --dry-run
bash scripts/install.sh --allow-experimental
```

The native locker must already be installed. The installer creates isolated user-owned theme files, an included font, and a launcher at `~/.local/bin/cosmic-gnome-lock`. It saves previous files for rollback. Existing PAM files, native default configuration, lock shortcuts and idle services are left untouched.

## Test before integration

Run the launcher only in the matching desktop/session:

```bash
"$HOME/.local/bin/cosmic-gnome-lock"
```

Confirm correct-password unlock, incorrect-password rejection and coverage of every monitor before assigning it to suspend or autolock. These native authentication checks were **not** performed in this repository's automated tests.

After GNOME discovers the newly installed extension (usually your next normal login), explicitly enable it: `gnome-extensions enable cosmic-lockscreen@thu12dta3`. Test the native screen lock. To disable styling immediately: `gnome-extensions disable cosmic-lockscreen@thu12dta3`. GNOME may use its normal clock-to-authentication transition; native widgets and system locale remain in use.

## Restore

First disable the extension with `gnome-extensions disable cosmic-lockscreen@thu12dta3`.

```bash
python3 scripts/rollback.py --backend gnome
```

The rollback restores only the files this installer manages. Restore any manual lock/idle binding changes using your saved configuration.

Code: GPL-3.0-or-later. Font: OFL-1.1, see `OFL.txt`. The included photograph retains its original licensing terms.
