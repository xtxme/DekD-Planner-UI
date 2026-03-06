#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="${TMPDIR%/}"

rm -rf "$ROOT_DIR/build" "$ROOT_DIR/.dart_tool"

tmp_flutter_tools=("$TMP_DIR"/flutter_tools.*)
if [ ${#tmp_flutter_tools[@]} -gt 0 ]; then
  rm -rf "${tmp_flutter_tools[@]}"
fi

echo "Cleanup completed."
