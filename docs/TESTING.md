# Tests and their limits

Run from the repository root:

```bash
python3 -m unittest discover -s tests -v
node tests/test_gnome_visual.mjs
node --input-type=module --check < themes/gnome/cosmic-lockscreen/extension.js
```

The Python suite checks shell/Python syntax, dry runs, the experimental install gate, staging and rollback of all four new backends (including paths with spaces), preservation of native configuration, legacy Plasma discovery, rejection of unknown Plasma APIs, and refusal to use the X11 locker under Wayland. Backend binaries are mocked in installation tests; no test password is supplied.

GNOME's mocked test checks native actor decoration, repeated updates, cleanup and unsupported-layout guards, and confirms native authentication methods are unchanged. It does not run GNOME Shell or authenticate.

Optional GTK3 rendering check (requires Python GObject/Gtk3 and a display):

```bash
python3 tests/render_gtklock.py /tmp/cosmic-gtklock-preview.png
```

Optional Hyprlang smoke test (requires C++23 compiler and installed Hyprlang development library):

```bash
g++ -std=c++23 tests/hyprlang-smoke.cpp -lhyprlang -o /tmp/cosmic-hyprlang-smoke
/tmp/cosmic-hyprlang-smoke themes/hyprlock/cosmic-lockscreen/hyprlock.conf
```

This validates native Hyprlang syntax and basic property types. Gradient/layout custom callbacks, compositor rendering, protocol locking and PAM are not exercised.

The Plasma 6.7.5 native testing window was authenticated manually by the system owner and logged `Unlocked`. No other backend has a real authentication result yet. See COMPATIBILITY.md and ROADMAP.md.
