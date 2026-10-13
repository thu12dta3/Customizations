#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
LIGHTDM_CONF=/etc/lightdm/lightdm.conf
WEBKIT_CONF=/etc/lightdm/lightdm-webkit2-greeter.conf
THEME_DEST=/usr/share/lightdm-webkit/themes/cosmic-login
GREETER_DESKTOP=/usr/share/xgreeters/lightdm-webkit2-greeter.desktop
MODE="${1:---apply}"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

case "$MODE" in
  --check|--apply) ;;
  *) die 'Uso: enable.sh [--check|--apply]' ;;
esac

[[ -f "$THEME_DIR/index.html" && -f "$THEME_DIR/main.js" && -f "$THEME_DIR/style.css" ]] || die 'Arquivos do Cosmic Login não foram encontrados.'
[[ -f "$THEME_DEST/index.html" ]] || die 'Tema não instalado em /usr/share/lightdm-webkit/themes/cosmic-login; execute scripts/stage.sh primeiro.'
[[ -x /usr/bin/lightdm-webkit2-greeter && -f "$GREETER_DESKTOP" ]] || die 'LightDM WebKit2 Greeter não está instalado corretamente.'
[[ "$(systemctl show display-manager.service -p Id --value 2>/dev/null)" == lightdm.service ]] || die 'O display manager ativo não é LightDM; nenhuma configuração foi alterada.'

TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

python3 - "$LIGHTDM_CONF" "$WEBKIT_CONF" "$TMP_DIR/lightdm.conf" "$TMP_DIR/webkit.conf" <<'PY'
from pathlib import Path
import re
import sys

lightdm_source, webkit_source, lightdm_out, webkit_out = map(Path, sys.argv[1:])

def set_key(text: str, section_name: str, key: str, value: str) -> str:
    lines = text.splitlines()
    section_indexes = [
        i for i, line in enumerate(lines)
        if re.fullmatch(r"\s*\[\s*" + re.escape(section_name) + r"\s*\]\s*(?:[#;].*)?", line, re.I)
    ]
    if not section_indexes:
        if lines and lines[-1].strip():
            lines.append("")
        lines.extend([f"[{section_name}]", f"{key}={value}"])
        return "\n".join(lines) + "\n"

    # Set the key in each matching section so a repeated section cannot
    # silently override the selected greeter later in the file.
    for start in reversed(section_indexes):
        end = next((i for i in range(start + 1, len(lines)) if re.match(r"\s*\[", lines[i])), len(lines))
        active = [i for i in range(start + 1, end) if re.match(r"\s*" + re.escape(key) + r"\s*=", lines[i], re.I)]
        if active:
            lines[active[0]] = f"{key}={value}"
            for i in reversed(active[1:]):
                lines.pop(i)
        else:
            lines.insert(end, f"{key}={value}")
    return "\n".join(lines) + "\n"

lightdm_text = lightdm_source.read_text() if lightdm_source.exists() else ""
webkit_text = webkit_source.read_text() if webkit_source.exists() else ""
lightdm_out.write_text(set_key(lightdm_text, "Seat:*", "greeter-session", "lightdm-webkit2-greeter"))
webkit_out.write_text(set_key(webkit_text, "greeter", "webkit_theme", "cosmic-login"))
PY

# Ask LightDM's own parser to read the staged file before touching /etc.
PARSED_CONFIG="$(lightdm --config="$TMP_DIR/lightdm.conf" --show-config 2>&1)" || die 'LightDM rejeitou a configuração preparada.'
grep -Fq 'greeter-session=lightdm-webkit2-greeter' <<<"$PARSED_CONFIG" || die 'A configuração preparada não seleciona o greeter WebKit.'
grep -Eq '^webkit_theme\s*=\s*cosmic-login\s*$' "$TMP_DIR/webkit.conf" || die 'A configuração preparada não seleciona o tema Cosmic Login.'

if [[ "$MODE" == --apply ]] \
  && grep -Fq 'greeter-session=lightdm-webkit2-greeter' < <(lightdm --show-config 2>&1) \
  && grep -Eq '^\s*webkit_theme\s*=\s*cosmic-login\s*$' "$WEBKIT_CONF"; then
  printf 'Cosmic Login já está selecionado no LightDM; nada foi alterado nem criado novo backup.\n'
  exit 0
fi

if [[ "$MODE" == --check ]]; then
  printf 'Prévia validada pelo parser do LightDM; nenhum arquivo do sistema foi alterado.\n'
  diff -u "$LIGHTDM_CONF" "$TMP_DIR/lightdm.conf" || true
  diff -u "$WEBKIT_CONF" "$TMP_DIR/webkit.conf" || true
  exit 0
fi

if [[ ${EUID} -ne 0 ]]; then
  exec sudo -- bash "$0" --apply
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/var/backups/cosmic-login-activation-$STAMP-$$"
install -d -o root -g root -m 0700 "$BACKUP_DIR"
cp -a -- "$LIGHTDM_CONF" "$BACKUP_DIR/lightdm.conf.original"
cp -a -- "$WEBKIT_CONF" "$BACKUP_DIR/lightdm-webkit2-greeter.conf.original"
{
  printf 'LightDM Cosmic Login activation backup\n'
  printf 'Created: %s\n' "$(date --iso-8601=seconds)"
  printf 'Changed files:\n  %s\n  %s\n' "$LIGHTDM_CONF" "$WEBKIT_CONF"
  printf 'Rollback: sudo bash %s/scripts/rollback.sh %s\n' "$THEME_DIR" "$BACKUP_DIR"
} > "$BACKUP_DIR/README.txt"
chmod 0600 "$BACKUP_DIR/README.txt"

install -o root -g root -m 0644 "$TMP_DIR/lightdm.conf" "$LIGHTDM_CONF"
install -o root -g root -m 0644 "$TMP_DIR/webkit.conf" "$WEBKIT_CONF"

printf 'Cosmic Login configurado para o próximo greeter do LightDM. Nenhum serviço foi reiniciado.\n'
printf 'Backup completo: %s\n' "$BACKUP_DIR"
printf 'Rollback: sudo bash %q %q\n' "$THEME_DIR/scripts/rollback.sh" "$BACKUP_DIR"
