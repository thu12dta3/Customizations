#!/usr/bin/env bash
set -euo pipefail
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cosmic-login"
BACKUP="${1:-$(cat "$STATE_DIR/lockscreen-backup.txt")}"
if [[ "$BACKUP" == /var/backups/cosmic-lockscreen-* && -f "$BACKUP/LockScreenUi.qml" ]]; then
  TARGET="$(cat "$BACKUP/target.txt" 2>/dev/null || printf '%s' /usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen)"
  [[ "$TARGET" == /*/plasma/shells/org.kde.plasma.desktop/contents/lockscreen ]] || { echo 'Invalid target in backup.' >&2; exit 1; }
  if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi
  for file in LockScreenUi.qml CosmicScene.qml JetBrainsMono-Regular.ttf OFL.txt cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg; do
    if [[ -f "$BACKUP/$file" ]]; then "${SUDO[@]}" cp -a "$BACKUP/$file" "$TARGET/$file"; else "${SUDO[@]}" rm -f -- "$TARGET/$file"; fi
  done
elif [[ "$BACKUP" == "$STATE_DIR"/lookandfeel-backup-* && -f "$BACKUP/theme-before.txt" ]]; then
  TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/look-and-feel/org.thu12.cosmic-lockscreen"
  PREVIOUS="$(cat "$BACKUP/theme-before.txt")"
  if [[ -n "$PREVIOUS" ]]; then kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme "$PREVIOUS"; else kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme --delete; fi
  if [[ -d "$BACKUP/package" ]]; then rm -rf -- "$TARGET"; cp -a "$BACKUP/package" "$TARGET"; else rm -rf -- "$TARGET"; fi
else
  echo 'Invalid Cosmic lockscreen backup.' >&2
  exit 1
fi
echo 'Previous screen lock UI restored for the next lock.'
