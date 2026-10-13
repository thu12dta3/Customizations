#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ ${XDG_SESSION_TYPE:-x11} == x11 && -z ${WAYLAND_DISPLAY:-} && -n ${DISPLAY:-} ]] || { echo 'This backend requires X11. Do not run it under XWayland as a Wayland lock.' >&2; exit 1; }
command -v i3lock >/dev/null || { echo 'Install i3lock-color first.' >&2; exit 1; }
HELP="$(i3lock --help 2>&1 || true)"
[[ "$HELP" == *--inside-color* ]] || { echo 'Plain i3lock is unsupported; i3lock-color is required.' >&2; exit 1; }
exec i3lock --nofork --image="$ROOT/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg" --fill \
  --clock --force-clock --time-str='%H:%M' --date-str='%A, %d %B %Y' \
  --time-font='JetBrains Mono' --date-font='Noto Sans' --time-size=72 --date-size=14 \
  --time-color=cdd6f4ff --date-color=a6adc8ff --time-align=1 --date-align=1 \
  --time-pos='x+w*0.09:y+h*0.39' --date-pos='x+w*0.09:y+h*0.45' \
  --ind-pos='x+w*0.12:y+h*0.59' --radius=25 --ring-width=2 \
  --inside-color=181825c2 --ring-color=cba6f7ff --keyhl-color=cba6f7ff --bshl-color=f38ba8ff \
  --insidever-color=313244c2 --ringver-color=cba6f7ff --insidewrong-color=181825c2 --ringwrong-color=f38ba8ff \
  --verif-color=cdd6f4ff --wrong-color=f38ba8ff --verif-text='Verificando…' --wrong-text='Senha incorreta' \
  --verif-pos='x+w*0.09:y+h*0.68' --wrong-pos='x+w*0.09:y+h*0.68' \
  "$@"
