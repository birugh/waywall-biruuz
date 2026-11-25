#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/maccel-waywall-state"
state=$(cat "$state_file" 2>/dev/null || printf 'normal')

case "$state" in
  reset)
    maccel set param sens-mult 1.0
    printf 'normal\n' > "$state_file"
    printf '(f7)\n'
    ;;
  normal)
    maccel set param sens-mult 0.10415
    printf 'zoom\n' > "$state_file"
    printf '(f7)\n'
    ;;
  zoom)
    maccel set param sens-mult 1.0
    printf 'normal\n' > "$state_file"
    printf '(f7)\n'
    ;;
  *)
    printf 'Refuse: unsupported state %s.\n' "$state" >&2
    exit 1
    ;;
esac
