#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/common.sh"
find_locker
find_backend
if [[ "$BACKEND" == shell ]]; then
  exec "$LOCKER" --testing --shell "$ROOT_DIR"
else
  exec "$LOCKER" --testing --theme "$ROOT_DIR/legacy"
fi
