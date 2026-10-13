#!/usr/bin/env bash
set -euo pipefail

LIGHTDM_CONF=/etc/lightdm/lightdm.conf
WEBKIT_CONF=/etc/lightdm/lightdm-webkit2-greeter.conf
WRAPPER=/usr/local/libexec/cosmic-login-webkit-wrapper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID} -eq 0 ]] || die 'Execute com sudo: sudo bash scripts/apply-nvidia-render-workaround.sh'
[[ "$(systemctl show display-manager.service -p Id --value 2>/dev/null)" == 'lightdm.service' ]] || die 'LightDM não é o display manager ativo.'
[[ -x /usr/bin/lightdm-webkit2-greeter ]] || die 'LightDM WebKit2 Greeter não está instalado.'
[[ -f "$WEBKIT_CONF" ]] || die 'Configuração do LightDM WebKit2 Greeter não foi encontrada.'
grep -Fq 'greeter-session=lightdm-webkit2-greeter' < <(lightdm --show-config 2>&1) || die 'O greeter WebKit2 não está selecionado no LightDM.'
grep -Eq '^\s*webkit_theme\s*=\s*cosmic-login\s*$' "$WEBKIT_CONF" || die 'Cosmic Login não está selecionado. Ative o tema antes de aplicar este ajuste.'

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/var/backups/cosmic-login-webkit-nvidia-$STAMP-$$"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT
install -d -o root -g root -m 0700 "$BACKUP_DIR"
cp -a -- "$LIGHTDM_CONF" "$BACKUP_DIR/lightdm.conf.original"
cp -a -- "$WEBKIT_CONF" "$BACKUP_DIR/lightdm-webkit2-greeter.conf.original"
if [[ -e "$WRAPPER" ]]; then
  cp -a -- "$WRAPPER" "$BACKUP_DIR/wrapper.original"
else
  : > "$BACKUP_DIR/wrapper.was-absent"
fi

cat > "$BACKUP_DIR/rollback.sh" <<'ROLLBACK'
#!/usr/bin/env bash
set -euo pipefail
[[ ${EUID} -eq 0 ]] || { echo 'Execute com sudo.' >&2; exit 1; }
[[ $# -eq 1 && -f "$1/lightdm.conf.original" && -f "$1/lightdm-webkit2-greeter.conf.original" ]] || { echo 'Informe o diretório exato do backup.' >&2; exit 1; }
BACKUP_DIR=$1
cp -a -- "$BACKUP_DIR/lightdm.conf.original" /etc/lightdm/lightdm.conf
cp -a -- "$BACKUP_DIR/lightdm-webkit2-greeter.conf.original" /etc/lightdm/lightdm-webkit2-greeter.conf
if [[ -f "$BACKUP_DIR/wrapper.was-absent" ]]; then
  rm -f -- /usr/local/libexec/cosmic-login-webkit-wrapper
elif [[ -f "$BACKUP_DIR/wrapper.original" ]]; then
  cp -a -- "$BACKUP_DIR/wrapper.original" /usr/local/libexec/cosmic-login-webkit-wrapper
fi
echo 'Configuração anterior restaurada. Reinicie o LightDM para aplicar.'
ROLLBACK
chmod 0700 "$BACKUP_DIR/rollback.sh"

python3 - "$LIGHTDM_CONF" "$TMP_DIR/lightdm.conf" "$WRAPPER" <<'PY'
from pathlib import Path
import os
import re
import stat
import sys
import tempfile

source, destination = map(Path, sys.argv[1:3])
wrapper = sys.argv[3]
lines = source.read_text().splitlines()
sections = [i for i, line in enumerate(lines)
            if re.fullmatch(r"\s*\[\s*Seat:\*\s*\]\s*(?:[#;].*)?", line, re.I)]
if not sections:
    raise SystemExit('Seção [Seat:*] não encontrada; nenhum arquivo de configuração foi alterado.')
for start in reversed(sections):
    end = next((i for i in range(start + 1, len(lines)) if re.match(r"\s*\[", lines[i])), len(lines))
    matches = [i for i in range(start + 1, end)
               if re.match(r"\s*#?\s*greeter-wrapper\s*=", lines[i], re.I)]
    if matches:
        lines[matches[0]] = f'greeter-wrapper={wrapper}'
        for index in reversed(matches[1:]):
            lines.pop(index)
    else:
        lines.insert(end, f'greeter-wrapper={wrapper}')

destination.write_text("\n".join(lines) + "\n")
os.chmod(destination, stat.S_IMODE(source.stat().st_mode))
PY

PARSED="$(lightdm --config="$TMP_DIR/lightdm.conf" --show-config 2>&1)" || die 'LightDM rejeitou a configuração preparada.'
grep -Fq 'greeter-session=lightdm-webkit2-greeter' <<<"$PARSED" || die 'A configuração preparada não mantém o greeter WebKit2.'
grep -Fq "greeter-wrapper=$WRAPPER" <<<"$PARSED" || die 'LightDM não reconheceu o wrapper preparado.'

install -d -o root -g root -m 0755 /usr/local/libexec
cat > "$TMP_DIR/cosmic-login-webkit-wrapper" <<'WRAPPER'
#!/bin/sh
# WebKitGTK rendering workarounds for some NVIDIA configurations.
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1
exec /usr/bin/lightdm-webkit2-greeter "$@"
WRAPPER
sh -n "$TMP_DIR/cosmic-login-webkit-wrapper"
install -o root -g root -m 0755 "$TMP_DIR/cosmic-login-webkit-wrapper" "$WRAPPER"
install -o root -g root -m 0644 "$TMP_DIR/lightdm.conf" "$LIGHTDM_CONF"

EFFECTIVE="$(lightdm --show-config 2>&1)"
grep -Fq "greeter-wrapper=$WRAPPER" <<<"$EFFECTIVE" || die 'A configuração gravada não seleciona o wrapper.'
grep -Fq 'greeter-session=lightdm-webkit2-greeter' <<<"$EFFECTIVE" || die 'A configuração gravada não mantém o greeter WebKit2.'
printf 'Ajuste de renderização instalado; Cosmic Login permanece selecionado.\n'
printf 'Nenhum serviço foi reiniciado.\nBackup: %s\nRollback: sudo bash %q %q\n' \
  "$BACKUP_DIR" "$BACKUP_DIR/rollback.sh" "$BACKUP_DIR"
