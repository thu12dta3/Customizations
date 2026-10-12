#!/usr/bin/env bash
set -euo pipefail

THEME_DEST="/usr/share/lightdm-webkit/themes/cosmic-login"
CONF_DIR="/etc/lightdm"
SEAT_SNIPPET="$CONF_DIR/lightdm.conf.d/50-cosmic-login.conf"
WEBKIT_CONF="$CONF_DIR/lightdm-webkit2-greeter.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CONF_DIR/cosmic-login-backup-$STAMP"

if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi
[[ -f "$THEME_DEST/index.html" ]] || { echo 'Execute scripts/stage.sh primeiro.' >&2; exit 1; }
[[ ! -e "$SEAT_SNIPPET" ]] || { echo "Já existe $SEAT_SNIPPET; faça a integração manualmente para preservar as opções existentes." >&2; exit 1; }
"${SUDO[@]}" install -d -o root -g root -m 0755 "$BACKUP_DIR" "$CONF_DIR/lightdm.conf.d"
for file in "$CONF_DIR/lightdm.conf" "$WEBKIT_CONF" "$SEAT_SNIPPET"; do
  if [[ -f "$file" ]]; then
    "${SUDO[@]}" cp -a "$file" "$BACKUP_DIR/$(basename "$file").original"
  fi
done
TMP_CONF="$(mktemp)"
trap 'rm -f "$TMP_CONF"' EXIT
python3 - "$WEBKIT_CONF" <<'PYCONF' > "$TMP_CONF"
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines() if path.exists() else []
section_start = None
section_end = len(lines)
for index, line in enumerate(lines):
    section = re.fullmatch(r"\s*\[\s*greeter\s*\]\s*(?:[#;].*)?", line, re.IGNORECASE)
    if section:
        section_start = index
        for end in range(index + 1, len(lines)):
            if re.match(r"\s*\[", lines[end]):
                section_end = end
                break
        break
if section_start is None:
    if lines and lines[-1].strip():
        lines.append("")
    lines.extend(["[greeter]", "webkit_theme = cosmic-login"])
else:
    key_index = next((i for i in range(section_start + 1, section_end) if re.match(r"\s*webkit_theme\s*=", lines[i], re.IGNORECASE)), None)
    if key_index is None:
        lines.insert(section_end, "webkit_theme = cosmic-login")
    else:
        lines[key_index] = "webkit_theme = cosmic-login"
print("\n".join(lines) + "\n", end="")
PYCONF
"${SUDO[@]}" install -o root -g root -m 0644 "$TMP_CONF" "$WEBKIT_CONF"
"${SUDO[@]}" tee "$SEAT_SNIPPET" >/dev/null <<'CONF'
[Seat:*]
greeter-session=lightdm-webkit2-greeter
CONF
printf 'Ativado para o próximo início do greeter. Nenhum serviço foi reiniciado.\nBackup: %s\n' "$BACKUP_DIR"
printf 'Não encerre a sessão atual. Reinicie o computador somente depois de confirmar o rollback disponível.\n'
