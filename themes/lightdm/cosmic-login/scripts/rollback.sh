#!/usr/bin/env bash
set -euo pipefail

CONF_DIR="/etc/lightdm"
SEAT_SNIPPET="$CONF_DIR/lightdm.conf.d/50-cosmic-login.conf"
WEBKIT_CONF="$CONF_DIR/lightdm-webkit2-greeter.conf"
if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi

"${SUDO[@]}" rm -f "$SEAT_SNIPPET"
shopt -s nullglob
backups=("$CONF_DIR"/cosmic-login-backup-*)
if ((${#backups[@]})); then
  latest="$(printf '%s\n' "${backups[@]}" | sort | tail -n 1)"
  if [[ -f "$latest/lightdm-webkit2-greeter.conf.original" ]]; then
    "${SUDO[@]}" cp -a "$latest/lightdm-webkit2-greeter.conf.original" "$WEBKIT_CONF"
  else
    "${SUDO[@]}" rm -f "$WEBKIT_CONF"
  fi
  printf 'Configuração revertida usando %s. O greeter ativo será escolhido no próximo início do LightDM.\n' "$latest"
else
  echo 'Nenhum backup de ativação Cosmic Login encontrado; a configuração atual do WebKit Greeter foi preservada.'
fi

THEME_DEST="/usr/share/lightdm-webkit/themes/cosmic-login"
shopt -s nullglob
theme_backups=(/var/backups/cosmic-login-*/theme.original)
if ((${#theme_backups[@]})); then
  latest_theme="$(printf '%s\n' "${theme_backups[@]}" | sort | tail -n 1)"
  "${SUDO[@]}" rm -rf -- "$THEME_DEST"
  "${SUDO[@]}" cp -a -- "$latest_theme" "$THEME_DEST"
  printf 'Tema anterior recuperado de %s.\n' "$latest_theme"
fi
