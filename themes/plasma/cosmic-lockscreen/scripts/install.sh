#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/common.sh"
find_locker
find_backend
printf 'Backend: %s\nLocker: %s\nDestination: %s\n' "$BACKEND" "$LOCKER" "$TARGET"
if [[ ${1:-} == --dry-run ]]; then exit 0; fi
if [[ ${1:-} != --authentication-tested ]]; then
  printf 'Run first: bash %q\n' "$ROOT_DIR/scripts/preview.sh"
  echo 'Only after the custom test window authenticates successfully, run with --authentication-tested.'
  exit 1
fi
SOURCE="$ROOT_DIR/contents/lockscreen"
FILES=(LockScreenUi.qml CosmicScene.qml JetBrainsMono-Regular.ttf OFL.txt cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg)
for file in "${FILES[@]}"; do [[ -s "$SOURCE/$file" ]] || { echo "Missing asset: $file" >&2; exit 1; }; done
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cosmic-login"
mkdir -p "$STATE_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)-$$"
if [[ "$BACKEND" == shell ]]; then
  if command -v kreadconfig6 >/dev/null; then
    ACTIVE_SHELL="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage --default org.kde.plasma.desktop)"
    [[ -z "$ACTIVE_SHELL" || "$ACTIVE_SHELL" == org.kde.plasma.desktop ]] || { echo 'A custom shell package is active; automatic installation stopped.' >&2; exit 1; }
  fi
  if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi
  BACKUP="/var/backups/cosmic-lockscreen-$STAMP"
  "${SUDO[@]}" install -d -m 0755 -o root -g root "$BACKUP"
  printf '%s\n' "$TARGET" | "${SUDO[@]}" tee "$BACKUP/target.txt" >/dev/null
  for file in "${FILES[@]}"; do
    if [[ -e "$TARGET/$file" ]]; then "${SUDO[@]}" cp -a "$TARGET/$file" "$BACKUP/$file"; fi
  done
  for file in "${FILES[@]}"; do "${SUDO[@]}" install -m 0644 -o root -g root "$SOURCE/$file" "$TARGET/$file"; done
else
  command -v kreadconfig6 >/dev/null && command -v kwriteconfig6 >/dev/null || { echo 'Plasma 6 configuration tools are required.' >&2; exit 1; }
  BACKUP="$STATE_DIR/lookandfeel-backup-$STAMP"
  mkdir -p "$BACKUP"
  kreadconfig6 --file kscreenlockerrc --group Greeter --key Theme > "$BACKUP/theme-before.txt" || true
  if [[ -d "$TARGET" ]]; then cp -a "$TARGET" "$BACKUP/package"; fi
  mkdir -p "$TARGET/contents/lockscreen"
  cp -L "$ROOT_DIR/legacy/metadata.json" "$TARGET/metadata.json"
  cp -L "$SOURCE/LockScreen.qml" "$TARGET/contents/lockscreen/LockScreen.qml"
  for file in "${FILES[@]}"; do cp -L "$SOURCE/$file" "$TARGET/contents/lockscreen/$file"; done
  kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme org.thu12.cosmic-lockscreen
fi
printf '%s\n' "$BACKUP" > "$STATE_DIR/lockscreen-backup.txt"
printf 'Installed for the next screen lock. Backup: %s\n' "$BACKUP"
printf 'Restore: bash %q %q\n' "$ROOT_DIR/scripts/rollback.sh" "$BACKUP"
