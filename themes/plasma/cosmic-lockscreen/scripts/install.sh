#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/contents/lockscreen"
TARGET="/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen"
if [[ ${1:-} != --authentication-tested ]]; then
  printf 'Teste primeiro com: /usr/lib/kscreenlocker_greet --testing --shell %q\n' "$ROOT_DIR"
  printf 'Depois de desbloquear a janela com sua senha, execute: %q --authentication-tested\n' "$0"
  exit 1
fi
[[ -f "$TARGET/LockScreen.qml" ]] || { echo 'Pacote de bloqueio do Plasma não encontrado.' >&2; exit 1; }
if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi
BACKUP="/var/backups/cosmic-lockscreen-$(date +%Y%m%d-%H%M%S)"
FILES=(LockScreenUi.qml CosmicScene.qml JetBrainsMono-Regular.ttf OFL.txt cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg)
"${SUDO[@]}" install -d -m 0755 -o root -g root "$BACKUP"
for file in "${FILES[@]}"; do
  [[ -f "$SOURCE/$file" ]] || { printf 'Arquivo ausente: %s\n' "$SOURCE/$file" >&2; exit 1; }
  if [[ -e "$TARGET/$file" ]]; then "${SUDO[@]}" cp -a "$TARGET/$file" "$BACKUP/$file"; fi
done
for file in "${FILES[@]}"; do
  "${SUDO[@]}" install -m 0644 -o root -g root "$SOURCE/$file" "$TARGET/$file"
done
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cosmic-login"
mkdir -p "$STATE_DIR"
printf '%s\n' "$BACKUP" > "$STATE_DIR/lockscreen-backup.txt"
printf 'Cosmic Login instalado para o próximo bloqueio. Backup: %s\n' "$BACKUP"
printf 'Restaurar: %q %q\n' "$ROOT_DIR/scripts/rollback.sh" "$BACKUP"
