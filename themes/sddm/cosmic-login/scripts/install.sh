#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DEST="/usr/share/sddm/themes/cosmic-login"
if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi

if [[ -e "$THEME_DEST" ]]; then
  BACKUP_DIR="/var/backups/cosmic-login-sddm-$(date +%Y%m%d-%H%M%S)"
  "${SUDO[@]}" install -d -o root -g root -m 0700 "$BACKUP_DIR"
  "${SUDO[@]}" cp -a "$THEME_DEST" "$BACKUP_DIR/theme.original"
  printf 'Existing theme backup: %s\n' "$BACKUP_DIR/theme.original"
fi

"${SUDO[@]}" install -d -o root -g root -m 0755 "$THEME_DEST"
"${SUDO[@]}" install -o root -g root -m 0644 "$ROOT_DIR/metadata.desktop" "$THEME_DEST/metadata.desktop"
"${SUDO[@]}" install -o root -g root -m 0644 "$ROOT_DIR/theme.conf" "$THEME_DEST/theme.conf"
"${SUDO[@]}" install -o root -g root -m 0644 "$ROOT_DIR/Main.qml" "$THEME_DEST/Main.qml"
"${SUDO[@]}" install -o root -g root -m 0644 "$ROOT_DIR/preview.png" "$THEME_DEST/preview.png"
"${SUDO[@]}" install -o root -g root -m 0644 "$ROOT_DIR/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg" "$THEME_DEST/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg"
printf 'Tema SDDM instalado em %s. O greeter ativo não foi alterado.\n' "$THEME_DEST"
