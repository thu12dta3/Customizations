# Cosmic Login — all-in-one lock-screen pack

This archive contains five lock-screen adapters. Choose one by your desktop, session type and native locker; do not choose by distribution name alone.

| Environment | Folder | Status |
| --- | --- | --- |
| KDE Plasma 6 | `themes/plasma/cosmic-lockscreen/` | Real authentication tested on Garuda / Plasma 6.7.5. Other Plasma versions still need their own test. |
| Hyprland + Hyprlock | `themes/hyprlock/cosmic-lockscreen/` | Experimental; native compositor/PAM test pending. |
| Sway / compatible wlroots + GTKLock | `themes/gtklock/cosmic-lockscreen/` | Experimental; real lock/PAM test pending. |
| GNOME Shell | `themes/gnome/cosmic-lockscreen/` | Experimental visual extension; native auth remains GNOME's. |
| X11 + i3lock-color | `themes/x11/cosmic-lockscreen/` | Experimental opt-in locker; not for Wayland/XWayland. |

Read that folder's README before installing. Detection does not change settings. The experimental installers require `--allow-experimental` and stage user-owned files only. They do not change PAM, lock shortcuts or idle services. No generic password form is used.

See `docs/COMPATIBILITY.md`, `docs/TESTING.md`, and `docs/ROADMAP.md` for support limits and testing steps. The complete source repository, separate LightDM/SDDM login themes and updates are at [thu12dta3/Customizations](https://github.com/thu12dta3/Customizations).
