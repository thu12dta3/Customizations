#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ${1:-} == --detect ]]; then
  printf 'Desktop: %s\nSession: %s\n' "${XDG_CURRENT_DESKTOP:-unknown}" "${XDG_SESSION_TYPE:-unknown}"
  for tool in plasmashell gnome-shell hyprlock gtklock i3lock; do command -v "$tool" || true; done
  echo 'Choose a backend from docs/COMPATIBILITY.md. Detection does not install or replace a locker.'
  exit 0
fi
[[ ${1:-} == --backend && $# -ge 2 ]] || { echo 'Usage: bash install.sh --detect | --backend plasma|hyprlock|gtklock|x11|gnome [backend options]'; exit 1; }
BACKEND="$2"; shift 2
case "$BACKEND" in
 plasma) exec bash "$ROOT/themes/plasma/cosmic-lockscreen/scripts/install.sh" "$@" ;;
 hyprlock|gtklock|x11|gnome) exec bash "$ROOT/themes/$BACKEND/cosmic-lockscreen/scripts/install.sh" "$@" ;;
 *) echo 'Unknown backend.' >&2; exit 1 ;;
esac
