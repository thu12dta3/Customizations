#!/usr/bin/env bash
set -euo pipefail
BACKUP="${1:?Informe o caminho absoluto do backup criado pelo instalador.}"
TARGET="/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen"
[[ "$BACKUP" == /var/backups/cosmic-lockscreen-* && -f "$BACKUP/LockScreenUi.qml" ]] || { echo 'Backup inválido.' >&2; exit 1; }
if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi
for file in LockScreenUi.qml CosmicScene.qml JetBrainsMono-Regular.ttf OFL.txt cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg; do
  if [[ -f "$BACKUP/$file" ]]; then
    "${SUDO[@]}" cp -a "$BACKUP/$file" "$TARGET/$file"
  else
    "${SUDO[@]}" rm -f -- "$TARGET/$file"
  fi
done
printf 'Tela de bloqueio anterior restaurada para o próximo bloqueio.\n'
