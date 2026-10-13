#!/usr/bin/env bash
set -euo pipefail

LIGHTDM_CONF=/etc/lightdm/lightdm.conf
WEBKIT_CONF=/etc/lightdm/lightdm-webkit2-greeter.conf

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ $# -eq 1 ]] || die 'Informe o caminho exato do backup impresso pelo instalador: rollback.sh /var/backups/cosmic-login-activation-DATA-HORA-PID'
BACKUP_DIR=$1

[[ "$BACKUP_DIR" == /var/backups/cosmic-login-activation-* ]] || die 'O backup precisa estar em /var/backups/cosmic-login-activation-*.'
[[ -f "$BACKUP_DIR/lightdm.conf.original" && -f "$BACKUP_DIR/lightdm-webkit2-greeter.conf.original" ]] || die 'O backup não contém os dois arquivos originais; nada foi alterado.'

if [[ ${EUID} -ne 0 ]]; then
  exec sudo -- bash "$0" "$BACKUP_DIR"
fi

cp -a -- "$BACKUP_DIR/lightdm.conf.original" "$LIGHTDM_CONF"
cp -a -- "$BACKUP_DIR/lightdm-webkit2-greeter.conf.original" "$WEBKIT_CONF"

PARSED_CONFIG="$(lightdm --config="$LIGHTDM_CONF" --show-config 2>&1)" || die 'Os arquivos foram restaurados, mas LightDM reportou erro ao lê-los.'
printf 'Configuração original restaurada a partir de %s. Nenhum serviço foi reiniciado.\n' "$BACKUP_DIR"
printf '%s\n' "$PARSED_CONFIG" | sed -n '/^   \[Seat:\*\]/,/^$/p'
