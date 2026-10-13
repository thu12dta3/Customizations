#!/usr/bin/env bash
# Shared discovery for Plasma installations with /usr/lib or /usr/libexec layouts.
find_locker() {
  local candidate base
  candidate="$(command -v kscreenlocker_greet || true)"
  if [[ -n "$candidate" ]]; then LOCKER="$candidate"; return; fi
  for base in /usr/libexec /usr/lib /usr/lib64 /usr/lib64/libexec /usr/lib/qt6/libexec /usr/lib/x86_64-linux-gnu/libexec /usr/lib/aarch64-linux-gnu/libexec /usr/lib/kf6; do
    candidate="$base/kscreenlocker_greet"
    if [[ -x "$candidate" ]]; then LOCKER="$candidate"; return; fi
  done
  echo 'Native Plasma screen locker not found. Install kscreenlocker through your distribution.' >&2
  return 1
}
find_backend() {
  local help data_dir version
  if command -v plasmashell >/dev/null; then
    version="$(plasmashell --version 2>/dev/null)"
    if [[ "$version" =~ ([0-9]+)\. && ${BASH_REMATCH[1]} != 6 ]]; then
      echo 'This package targets Plasma 6. Other major versions are unsupported.' >&2
      return 1
    fi
  fi
  help="$("$LOCKER" --help 2>&1)"
  if [[ "$help" == *--shell* ]]; then
    BACKEND=shell
    TARGET=''
    local -a data_dirs
    IFS=: read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    data_dirs+=(/usr/share /usr/local/share)
    for data_dir in "${data_dirs[@]}"; do
      if [[ -f "$data_dir/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreen.qml" ]]; then
        TARGET="$data_dir/plasma/shells/org.kde.plasma.desktop/contents/lockscreen"
        return
      fi
    done
    echo 'Default Plasma shell lockscreen package not found; no files were changed.' >&2
    return 1
  elif [[ "$help" == *--theme* ]]; then
    BACKEND=lookandfeel
    TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/look-and-feel/org.thu12.cosmic-lockscreen"
  else
    echo 'Unsupported Plasma locker API; no files were changed.' >&2
    return 1
  fi
}
