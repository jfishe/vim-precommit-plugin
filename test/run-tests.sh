#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VADER_DIR="${VADER_DIR:-}"

if [[ -z "$VADER_DIR" || ! -f "$VADER_DIR/plugin/vader.vim" ]]; then
  echo "Set VADER_DIR to a vader.vim checkout before running tests." >&2
  exit 1
fi

cd "$ROOT_DIR"
vim -Nu test/vimrc -n -es "+Vader! test/*.vader" +qall
