#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -d "$ROOT_DIR/theme" ]]; then
  THEME_SOURCE="$ROOT_DIR/theme"
else
  THEME_SOURCE="$ROOT_DIR"
fi
THEME_DEST="/usr/share/lightdm-webkit/themes/cosmic-login"

if [[ $EUID -eq 0 ]]; then
  SUDO=()
else
  SUDO=(sudo)
fi

if ! command -v lightdm-webkit2-greeter >/dev/null 2>&1; then
  "${SUDO[@]}" pacman -S --needed lightdm-webkit2-greeter
fi

if [[ -e "$THEME_DEST" ]]; then
  BACKUP_DIR="/var/backups/cosmic-login-$(date +%Y%m%d-%H%M%S)"
  "${SUDO[@]}" install -d -o root -g root -m 0700 "$BACKUP_DIR"
  "${SUDO[@]}" cp -a "$THEME_DEST" "$BACKUP_DIR/theme.original"
  printf 'Existing theme backup: %s\n' "$BACKUP_DIR/theme.original"
fi

"${SUDO[@]}" install -d -o root -g root -m 0755 "$THEME_DEST"
"${SUDO[@]}" install -o root -g root -m 0644 "$THEME_SOURCE/index.theme" "$THEME_DEST/index.theme"
"${SUDO[@]}" install -o root -g root -m 0644 "$THEME_SOURCE/index.html" "$THEME_DEST/index.html"
"${SUDO[@]}" install -o root -g root -m 0644 "$THEME_SOURCE/style.css" "$THEME_DEST/style.css"
"${SUDO[@]}" install -o root -g root -m 0644 "$THEME_SOURCE/main.js" "$THEME_DEST/main.js"
"${SUDO[@]}" install -o root -g root -m 0644 "$THEME_SOURCE/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg" "$THEME_DEST/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg"

printf 'Tema instalado em %s. O greeter ativo NÃO foi alterado.\n' "$THEME_DEST"
printf 'Revise README.md; faça backup antes de ativar.\n'
