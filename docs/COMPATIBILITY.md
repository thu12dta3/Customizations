# Pick your desktop and locker

Support is determined by the **desktop, session protocol and locker**, not the distribution name or display manager. The existing LightDM/SDDM folders customize login screens; these packages customize session locking.

| Environment | Package | Status / evidence |
| --- | --- | --- |
| KDE Plasma 6.7.5, default shell, Garuda | [Plasma ZIP](../downloads/cosmic-lockscreen.zip) | Native KDE testing window accepted the user's password and logged `Unlocked`. Current native UI loads and resources match. Other distributions/versions still require their own test. |
| Earlier Plasma 6 using LookAndFeel | Same Plasma ZIP | API/path detection and packaged assets tested; real legacy authentication pending. |
| Hyprland with Hyprlock 0.9.x | [Hyprlock ZIP](../downloads/cosmic-lockscreen-hyprlock-experimental.zip) | Experimental. Native Hyprlang syntax/basic types checked; compositor/GPU/PAM pending. |
| Sway / compatible wlroots compositor with GTKLock 4.x | [GTKLock ZIP](../downloads/cosmic-lockscreen-gtklock-experimental.zip) | Experimental. GTK3 CSS, native widget IDs and rendering checked; ext-session-lock/PAM pending. |
| GNOME Shell 46–51 | [GNOME ZIP](../downloads/cosmic-lockscreen-gnome-experimental.zip) | Experimental visual extension. JS syntax and mocked lifecycle/cleanup checked; real Shell/PAM pending. No authentication methods are replaced. |
| XFCE, MATE, Cinnamon, LXQt, i3 and other **X11** sessions | [X11 ZIP](../downloads/cosmic-lockscreen-x11-experimental.zip) | Experimental opt-in i3lock-color alternative. Native CLI flags checked; real X11/PAM and desktop idle integration pending. It does not directly theme those desktops' default screensaver. |
| Any other Linux desktop/session | No verified package yet | Do not claim universal support. Request a native adapter and include desktop, session, locker and versions. |

The new adapters stage user-owned files and separate launchers. They do not change lock shortcuts or idle services automatically. GNOME styling must be explicitly enabled after installation. Use the package-specific README before assigning any launcher to suspend/autolock.

Native widgets differ: Plasma has the full card and native power actions; GTKLock keeps GTK prompt widgets; GNOME retains its native auth mechanisms and page transitions; X11 uses i3lock-color's native indicator. The theme does not implement a generic cross-desktop password form.

## Distribution portability

The installers do not assume pacman, apt, dnf or zypper. Install the required native locker through your distribution, then use the package. Plasma's native executable and data path are discovered rather than tied to Arch's `/usr/lib` layout. This improves portability; it is not proof that every distribution has passed a lock/unlock test.

Primary references: [KDE locker source](https://github.com/KDE/kscreenlocker), [Hyprlock](https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/), [GTKLock](https://github.com/jovanlanik/gtklock), [GNOME's native unlock dialog](https://github.com/GNOME/gnome-shell/blob/main/js/ui/unlockDialog.js), [i3lock-color](https://github.com/Raymo111/i3lock-color).
