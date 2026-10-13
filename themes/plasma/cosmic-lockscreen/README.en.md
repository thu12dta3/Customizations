# Cosmic Login — KDE Plasma lock screen

A left-aligned cosmic lock screen with the original Milky Way photograph, Catppuccin Mocha colors, JetBrains Mono clock, Brazilian Portuguese date and labels, account photo, and a compact password arrow. This package customizes normal Plasma screen locking (Meta+L).

## Download and install

[Download the standalone ZIP](https://github.com/thu12dta3/Customizations/raw/refs/heads/main/downloads/cosmic-lockscreen.zip). Extract it and open a terminal inside the `cosmic-lockscreen` folder. No repository clone is needed. All resources are included as regular files.

Tested with real password authentication on **KDE Plasma 6.7.5**. Other versions/distributions are not confirmed compatible. Requires Bash, the native Plasma screen locker, Qt Quick Controls, and Qt5Compat GraphicalEffects. The installer discovers the native locker in `/usr/lib`, `/usr/libexec`, and common multiarch paths, then detects the shell or legacy LookAndFeel API. Legacy Plasma 6 support is experimental until tested on a real legacy installation. Use `bash scripts/install.sh --dry-run` to inspect discovery without changing files.

First open a testing window:

```bash
bash scripts/preview.sh
```

Enter your system password directly into the testing window. Proceed only if the custom interface appears and closes after successful authentication. If it fails or shows the default fallback interface, close the test window and do not install.

```bash
bash scripts/install.sh --authentication-tested
```

The installer uses sudo, backs up the existing UI, and installs the resources for your next normal screen lock. It does not lock, log out, reboot, change the display manager, or change your global desktop theme. Passwords go directly to Plasma's native authenticator; they are not saved by the theme.

## Restore

The installer prints the backup location and records it in `~/.local/state/cosmic-login/lockscreen-backup.txt`. Restore from inside the extracted folder:

```bash
bash scripts/rollback.sh "$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/cosmic-login/lockscreen-backup.txt")"
```

Plasma 6.7 loads this UI from its shell package. The installer replaces that package's `LockScreenUi.qml` and adds the local scene, font and image resources; it preserves the original `LockScreen.qml` and native authentication engine. A plasma-workspace update may restore the original UI. Test again before reinstalling after upgrades.

![Preview](preview.png)

Code: GPL-3.0-or-later, see `LICENSE`. JetBrains Mono: OFL-1.1, see `contents/lockscreen/OFL.txt`. The photograph retains its original licensing terms. The snapshot is illustrative: the running lock screen uses your account and current time.

For older Plasma 6 lockers with `--theme`, the installer uses a user-level LookAndFeel package and saves/restores the previous Greeter/Theme setting. Modern `--shell` lockers use the existing default shell package, with the discovered destination recorded in the system backup. No distribution-specific package command is run.
