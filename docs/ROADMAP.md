# Compatibility stages

## Stage 1 — packages and installation portability

- [x] Preserve the tested Plasma 6.7.5 implementation.
- [x] Discover distribution-specific native locker/data locations.
- [x] Add a legacy Plasma 6 LookAndFeel installation path.
- [x] Add separate Hyprlock, GTKLock, GNOME and X11/i3lock-color adapters.
- [x] Package regular standalone assets, native launchers, backup and rollback.
- [x] Publish downloads and distinguish tested vs experimental backends.

## Stage 2 — real authentication and desktop integration

- [ ] Test legacy Plasma 6 native authentication on an older installation.
- [ ] Test modern Plasma on Debian/Ubuntu, Fedora and openSUSE.
- [ ] Test Hyprlock in Hyprland with correct/incorrect passwords and suspend.
- [ ] Test GTKLock in Sway with ext-session-lock, multiple monitors and suspend.
- [ ] Test the GNOME extension in real Shell sessions for each allowed major version, including enable/disable while locked and all native authentication mechanisms.
- [ ] Test i3lock-color in XFCE, MATE, Cinnamon and LXQt X11 sessions and integrate their idle/lock commands explicitly.

Automated installation, parser and UI tests are not substitutes for these authentication/session tests. A backend moves from experimental to verified only after recording the desktop/locker versions and a real test result.

## Stage 3 — remaining native variants

- [ ] Evaluate native xfce4-screensaver/mate-screensaver/cinnamon-screensaver customization where supported, rather than requiring an alternative locker.
- [ ] Evaluate additional Wayland desktops and compositors individually.
- [ ] Add translations and responsive/multi-monitor refinements from real session feedback.

Report results through the repository's Issues with desktop version, X11/Wayland session, locker version, package used, and whether wrong passwords stay locked and correct passwords unlock. Never include passwords or authentication tokens.
