# Cosmic Login · Linux lock screens

[Português](README.pt-BR.md) · [Compatibility](docs/COMPATIBILITY.md) · [Tests](docs/TESTING.md) · [Roadmap](docs/ROADMAP.md)

A family of cosmic screen-lock themes with the original Milky Way photograph, Catppuccin Mocha colors and a left-aligned clock/login composition. Choose the package for your **desktop and locker**, then follow its included instructions.

**Verified:** native Plasma testing-window authentication on Garuda / KDE Plasma 6.7.5. The additional adapters are **experimental**; their installation/UI/parser tests do not establish successful native authentication. This project does not claim to work on every Linux system yet.

| Your environment | Download | Instructions |
| --- | --- | --- |
| KDE Plasma 6 | [Plasma ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen.zip) | [English](themes/plasma/cosmic-lockscreen/README.en.md) / [Português](themes/plasma/cosmic-lockscreen/README.md). Modern native test passed; legacy LookAndFeel path is experimental. |
| Hyprland + Hyprlock | [Experimental ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-hyprlock-experimental.zip) | [Hyprlock guide](themes/hyprlock/cosmic-lockscreen/README.md) |
| Sway / compatible wlroots + GTKLock | [Experimental ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-gtklock-experimental.zip) | [GTKLock guide](themes/gtklock/cosmic-lockscreen/README.md) |
| GNOME Shell | [Experimental ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-gnome-experimental.zip) | [GNOME extension guide](themes/gnome/cosmic-lockscreen/README.md) |
| XFCE, MATE, Cinnamon, LXQt or another **X11** session | [Experimental ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-x11-experimental.zip) | [i3lock-color alternative guide](themes/x11/cosmic-lockscreen/README.md). Explicit desktop integration required; this does not directly theme the default screensaver. |

Want all adapters? [Download the complete lockscreen bundle](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreens-all.zip). All ZIPs include regular files, assets, font, license, installer and rollback. SHA-256 files are in [`downloads/`](downloads/).

## Get started

For an individual ZIP, extract it and follow its README. For a clone or complete bundle:

```bash
bash install.sh --detect
```

Detection prints the desktop, session and installed lockers without changing settings. Select the corresponding guide above. The installers do not install operating-system packages or automatically change your lock shortcuts, idle services or display manager.

![Cosmic Plasma preview — the validated variant](themes/plasma/cosmic-lockscreen/preview.png)

Native controls differ across platforms. The packages use each locker's authentication; there is no generic cross-desktop password collector. Before assigning an experimental launcher to suspend/autolock, verify correct-password unlock, wrong-password rejection and coverage of all monitors on your own system.

## Other customizations

| Folder | Purpose |
| --- | --- |
| [`themes/lightdm/cosmic-login/`](themes/lightdm/cosmic-login/) | LightDM WebKit2 **login** theme; [black-screen/NVIDIA troubleshooting](themes/lightdm/cosmic-login/TROUBLESHOOTING.en.md). |
| [`themes/sddm/cosmic-login/`](themes/sddm/cosmic-login/) | SDDM **login** theme and KDE login-theme chooser preview. |
| [`themes/shared/`](themes/shared/) | Shared visuals, font and user-level packaging helpers. |

A login theme is separate from the screen lock used inside your session. Code is GPL-3.0-or-later except files retaining upstream license terms (noted beside them). JetBrains Mono is OFL-1.1; the photograph retains its original terms.
