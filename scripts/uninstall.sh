#!/usr/bin/env bash
set -Eeuo pipefail
APP_NAME='share-desk-gpt'
ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/$APP_NAME"
BIN="${XDG_BIN_HOME:-$HOME/.local/bin}/$APP_NAME"
rm -f "$BIN" 2>/dev/null || true
rm -rf "$ROOT"
rm -f "/usr/local/bin/$APP_NAME" "/usr/bin/$APP_NAME" 2>/dev/null || true
printf 'User-local share-desk-gpt files removed. Review PATH entries manually if desired.\n'
